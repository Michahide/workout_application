import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/syncable_table_mixin.dart';
import '../../../core/database/tables.dart';

part 'gym_location_repository.g.dart';

/// Composite model combining a [GymMachine] with its linked [Exercise] and optional [GymLocation].
class GymMachineWithDetails {
  const GymMachineWithDetails({
    required this.machine,
    required this.exercise,
    this.gymLocation,
  });

  final GymMachine machine;
  final Exercise exercise;
  final GymLocation? gymLocation;
}

/// Offline-first repository for managing [GymLocations] and [GymMachines].
///
/// Strictly enforces:
/// - `WHERE deleted_at IS NULL` on all SELECT queries
/// - Client-generated UUID v4 on INSERT
/// - `updatedAt = DateTime.now().toUtc()` and `syncStatus = SyncStatus.pendingPush` on INSERT/UPDATE
/// - Soft-delete (`deletedAt = DateTime.now().toUtc()`, `syncStatus = SyncStatus.pendingDelete`) on DELETE
class GymLocationRepository {
  GymLocationRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ---------------------------------------------------------------------------
  // GYM LOCATIONS CRUD
  // ---------------------------------------------------------------------------

  /// Watches all active (non-deleted) gym locations ordered by name.
  Stream<List<GymLocation>> watchGymLocations() {
    final query = _db.select(_db.gymLocations)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.watch();
  }

  /// Fetches all active (non-deleted) gym locations ordered by name.
  Future<List<GymLocation>> getGymLocations() {
    final query = _db.select(_db.gymLocations)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.get();
  }

  /// Watches a single active gym location by [id].
  Stream<GymLocation?> watchGymLocationById(String id) {
    final query = _db.select(_db.gymLocations)
      ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull());
    return query.watchSingleOrNull();
  }

  /// Creates a new gym location and marks `syncStatus = SyncStatus.pendingPush`.
  Future<String> createGymLocation({
    required String name,
    String? address,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.gymLocations).insert(
          GymLocationsCompanion.insert(
            id: Value(id),
            name: name.trim(),
            address: Value(_nullIfEmpty(address)),
            notes: Value(_nullIfEmpty(notes)),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncStatus: Value(SyncStatus.pendingPush),
          ),
        );
    return id;
  }

  /// Updates an existing active gym location and marks `syncStatus = SyncStatus.pendingPush`.
  Future<void> updateGymLocation({
    required String id,
    required String name,
    String? address,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.gymLocations)
          ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull()))
        .write(
      GymLocationsCompanion(
        name: Value(name.trim()),
        address: Value(_nullIfEmpty(address)),
        notes: Value(_nullIfEmpty(notes)),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingPush),
      ),
    );
  }

  /// Soft-deletes a gym location and all machines tied to that gym location.
  Future<void> softDeleteGymLocation(String id) async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.gymLocations)
            ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull()))
          .write(
        GymLocationsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: Value(SyncStatus.pendingDelete),
        ),
      );

      await (_db.update(_db.gymMachines)
            ..where(
              (tbl) => tbl.gymLocationId.equals(id) & tbl.deletedAt.isNull(),
            ))
          .write(
        GymMachinesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: Value(SyncStatus.pendingDelete),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // GYM MACHINES CRUD
  // ---------------------------------------------------------------------------

  /// Watches all active machines registered at a specific [gymLocationId],
  /// joined with their linked [Exercise] and [GymLocation].
  Stream<List<GymMachineWithDetails>> watchMachinesForGym(
    String gymLocationId,
  ) {
    final query = _db.select(_db.gymMachines).join([
      innerJoin(
        _db.exercises,
        _db.exercises.id.equalsExp(_db.gymMachines.exerciseId) &
            _db.exercises.deletedAt.isNull(),
      ),
      leftOuterJoin(
        _db.gymLocations,
        _db.gymLocations.id.equalsExp(_db.gymMachines.gymLocationId) &
            _db.gymLocations.deletedAt.isNull(),
      ),
    ])
      ..where(
        _db.gymMachines.gymLocationId.equals(gymLocationId) &
            _db.gymMachines.deletedAt.isNull(),
      )
      ..orderBy([
        OrderingTerm.asc(_db.exercises.name),
        OrderingTerm.asc(_db.gymMachines.brandName),
      ]);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => GymMachineWithDetails(
              machine: row.readTable(_db.gymMachines),
              exercise: row.readTable(_db.exercises),
              gymLocation: row.readTableOrNull(_db.gymLocations),
            ),
          )
          .toList(growable: false);
    });
  }

  /// Watches all active machines linked to a specific [exerciseId] across all gyms.
  Stream<List<GymMachineWithDetails>> watchMachinesForExercise(
    String exerciseId,
  ) {
    final query = _db.select(_db.gymMachines).join([
      innerJoin(
        _db.exercises,
        _db.exercises.id.equalsExp(_db.gymMachines.exerciseId) &
            _db.exercises.deletedAt.isNull(),
      ),
      leftOuterJoin(
        _db.gymLocations,
        _db.gymLocations.id.equalsExp(_db.gymMachines.gymLocationId) &
            _db.gymLocations.deletedAt.isNull(),
      ),
    ])
      ..where(
        _db.gymMachines.exerciseId.equals(exerciseId) &
            _db.gymMachines.deletedAt.isNull() &
            (_db.gymMachines.gymLocationId.isNull() |
                _db.gymLocations.id.isNotNull()),
      )
      ..orderBy([
        OrderingTerm.asc(_db.gymLocations.name),
        OrderingTerm.asc(_db.gymMachines.brandName),
      ]);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => GymMachineWithDetails(
              machine: row.readTable(_db.gymMachines),
              exercise: row.readTable(_db.exercises),
              gymLocation: row.readTableOrNull(_db.gymLocations),
            ),
          )
          .toList(growable: false);
    });
  }

  /// Creates a new [GymMachine] tied to a [gymLocationId] (nullable for global equipment)
  /// and an [exerciseId].
  Future<String> createGymMachine({
    required String exerciseId,
    String? gymLocationId,
    String? brandName,
    WeightUnit weightUnit = WeightUnit.KG,
    String? pinnedNotes,
  }) async {
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.gymMachines).insert(
          GymMachinesCompanion.insert(
            id: Value(id),
            gymLocationId: Value(_nullIfEmpty(gymLocationId)),
            exerciseId: exerciseId,
            brandName: Value(_nullIfEmpty(brandName)),
            weightUnit: Value(weightUnit),
            pinnedNotes: Value(_nullIfEmpty(pinnedNotes)),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncStatus: Value(SyncStatus.pendingPush),
          ),
        );
    return id;
  }

  /// Updates an existing active [GymMachine] and marks `syncStatus = SyncStatus.pendingPush`.
  Future<void> updateGymMachine({
    required String id,
    required String exerciseId,
    String? gymLocationId,
    String? brandName,
    required WeightUnit weightUnit,
    String? pinnedNotes,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.gymMachines)
          ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull()))
        .write(
      GymMachinesCompanion(
        gymLocationId: Value(_nullIfEmpty(gymLocationId)),
        exerciseId: Value(exerciseId),
        brandName: Value(_nullIfEmpty(brandName)),
        weightUnit: Value(weightUnit),
        pinnedNotes: Value(_nullIfEmpty(pinnedNotes)),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingPush),
      ),
    );
  }

  /// Soft-deletes a [GymMachine] (`deletedAt = now`, `syncStatus = SyncStatus.pendingDelete`).
  Future<void> softDeleteGymMachine(String id) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.gymMachines)
          ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull()))
        .write(
      GymMachinesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingDelete),
      ),
    );
  }

  String? _nullIfEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

@Riverpod(keepAlive: true)
GymLocationRepository gymLocationRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return GymLocationRepository(db);
}
