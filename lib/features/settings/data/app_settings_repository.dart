import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/seed_data.dart';
import '../../../core/database/syncable_table_mixin.dart';
import '../../../core/database/tables.dart';

part 'app_settings_repository.g.dart';

/// Offline-first repository for managing singleton [AppSettings] configuration.
class AppSettingsRepository {
  AppSettingsRepository(this._db);

  final AppDatabase _db;

  /// Watches the active [AppSetting] row, seeding defaults if not yet present.
  Stream<AppSetting> watchSettings() {
    final query = _db.select(_db.appSettings)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..limit(1);

    return query.watchSingleOrNull().asyncMap((row) async {
      if (row != null) return row;
      return getSettings();
    });
  }

  /// Fetches the active [AppSetting] row, creating the default row if needed.
  Future<AppSetting> getSettings() async {
    final existing = await (_db.select(_db.appSettings)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) return existing;

    final now = DateTime.now().toUtc();
    final companion = AppSettingsCompanion.insert(
      id: const Value(kDefaultAppSettingsId),
      useSplitWarmupRest: const Value(true),
      largeMuscleWarmupRestSeconds: const Value(90),
      smallMuscleWarmupRestSeconds: const Value(60),
      globalWarmupRestSeconds: const Value(60),
      defaultWorkingSetRestSeconds: const Value(180),
      createdAt: Value(now),
      updatedAt: Value(now),
      syncStatus: Value(SyncStatus.pendingPush),
    );

    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(companion);

    return (_db.select(_db.appSettings)
          ..where((tbl) => tbl.id.equals(kDefaultAppSettingsId)))
        .getSingle();
  }

  /// Persists updated rest timer settings to SQLite and marks `syncStatus = SyncStatus.pendingPush`.
  Future<void> updateSettings({
    required bool useSplitWarmupRest,
    required int largeMuscleWarmupRestSeconds,
    required int smallMuscleWarmupRestSeconds,
    required int globalWarmupRestSeconds,
    required int defaultWorkingSetRestSeconds,
  }) async {
    final current = await getSettings();
    final now = DateTime.now().toUtc();

    await (_db.update(_db.appSettings)
          ..where((tbl) => tbl.id.equals(current.id) & tbl.deletedAt.isNull()))
        .write(
      AppSettingsCompanion(
        useSplitWarmupRest: Value(useSplitWarmupRest),
        largeMuscleWarmupRestSeconds: Value(
          largeMuscleWarmupRestSeconds.clamp(10, 900),
        ),
        smallMuscleWarmupRestSeconds: Value(
          smallMuscleWarmupRestSeconds.clamp(10, 900),
        ),
        globalWarmupRestSeconds: Value(
          globalWarmupRestSeconds.clamp(10, 900),
        ),
        defaultWorkingSetRestSeconds: Value(
          defaultWorkingSetRestSeconds.clamp(10, 900),
        ),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingPush),
      ),
    );
  }

  /// Resolves the target rest duration in seconds according to SPEC.md rules:
  /// 1. Warm-up set (`SetType.warmup`):
  ///    - If `useSplitWarmupRest == true`: `largeMuscleWarmupRestSeconds` for `LARGE`
  ///      or `smallMuscleWarmupRestSeconds` for `SMALL`.
  ///    - If `useSplitWarmupRest == false`: `globalWarmupRestSeconds`.
  /// 2. Working set (`normal`, `dropset`, `failure`):
  ///    - Uses custom target rest (from set/plan/exercise) or falls back to
  ///      `defaultWorkingSetRestSeconds`.
  static int resolveTargetRestSeconds({
    required AppSetting settings,
    required SetType setType,
    required MuscleSizeCategory muscleSizeCategory,
    int? customWorkingRestSeconds,
  }) {
    if (setType == SetType.warmup) {
      if (settings.useSplitWarmupRest) {
        return muscleSizeCategory == MuscleSizeCategory.LARGE
            ? settings.largeMuscleWarmupRestSeconds
            : settings.smallMuscleWarmupRestSeconds;
      }
      return settings.globalWarmupRestSeconds;
    }

    if (customWorkingRestSeconds != null && customWorkingRestSeconds > 0) {
      return customWorkingRestSeconds;
    }
    return settings.defaultWorkingSetRestSeconds;
  }
}

@Riverpod(keepAlive: true)
AppSettingsRepository appSettingsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppSettingsRepository(db);
}

final appSettingsStreamProvider = StreamProvider.autoDispose<AppSetting>((ref) {
  final repo = ref.watch(appSettingsRepositoryProvider);
  return repo.watchSettings();
});
