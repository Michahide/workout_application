import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/syncable_table_mixin.dart';
import '../../../core/database/tables.dart';
import '../../../core/media/media_compression_service.dart';

part 'exercise_library_repository.g.dart';

/// Exception thrown when adding media exceeds the per-exercise limit
/// (max 4 photos or max 3 videos).
class ExerciseMediaLimitException implements Exception {
  const ExerciseMediaLimitException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Offline-first repository for managing [Exercises] and [ExerciseMedia].
///
/// Strictly enforces:
/// - `WHERE deleted_at IS NULL` on all SELECT queries
/// - Client-generated UUID v4 on INSERT
/// - `updatedAt = DateTime.now().toUtc()` and `syncStatus = SyncStatus.pendingPush` on INSERT/UPDATE
/// - Soft-delete (`deletedAt = DateTime.now().toUtc()`, `syncStatus = SyncStatus.pendingDelete`) on DELETE
/// - Max 4 active photos & max 3 active videos per exercise
class ExerciseLibraryRepository {
  ExerciseLibraryRepository(this._db, this._mediaCompressionService);

  final AppDatabase _db;
  final MediaCompressionService _mediaCompressionService;

  static const _uuid = Uuid();
  static const int maxPhotosPerExercise = 4;
  static const int maxVideosPerExercise = 3;

  // ---------------------------------------------------------------------------
  // EXERCISES READ / SEARCH / FILTER
  // ---------------------------------------------------------------------------

  /// Watches all active (non-deleted) exercises matching the optional search & filter criteria.
  Stream<List<Exercise>> watchExercises({
    String searchQuery = '',
    MuscleGroup? primaryMuscleGroup,
    EquipmentCategory? equipmentCategory,
    ExerciseType? exerciseType,
  }) {
    final trimmedQuery = searchQuery.trim().toLowerCase();
    final query = _db.select(_db.exercises)
      ..where((tbl) {
        Expression<bool> predicate = tbl.deletedAt.isNull();
        if (trimmedQuery.isNotEmpty) {
          predicate = predicate & tbl.name.lower().like('%$trimmedQuery%');
        }
        if (primaryMuscleGroup != null) {
          predicate =
              predicate & tbl.primaryMuscleGroup.equals(primaryMuscleGroup.name);
        }
        if (equipmentCategory != null) {
          predicate =
              predicate & tbl.equipmentCategory.equals(equipmentCategory.name);
        }
        if (exerciseType != null) {
          predicate = predicate & tbl.exerciseType.equals(exerciseType.name);
        }
        return predicate;
      })
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);

    return query.watch();
  }

  /// Watches a single active exercise by [id].
  Stream<Exercise?> watchExerciseById(String id) {
    final query = _db.select(_db.exercises)
      ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull());
    return query.watchSingleOrNull();
  }

  // ---------------------------------------------------------------------------
  // EXERCISES CREATE / UPDATE / SOFT-DELETE
  // ---------------------------------------------------------------------------

  /// Creates a custom exercise. Automatically infers [muscleSizeCategory] from
  /// [primaryMuscleGroup.defaultSizeCategory] unless [muscleSizeCategoryOverride] is provided.
  Future<String> createCustomExercise({
    required String name,
    required EquipmentCategory equipmentCategory,
    required MuscleGroup primaryMuscleGroup,
    List<MuscleGroup> secondaryMuscleGroups = const [],
    MuscleSizeCategory? muscleSizeCategoryOverride,
    required ExerciseType exerciseType,
    int? defaultWorkingRestSeconds,
  }) async {
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final resolvedMuscleSize =
        muscleSizeCategoryOverride ?? primaryMuscleGroup.defaultSizeCategory;
    final sanitizedSecondary = secondaryMuscleGroups
        .where((m) => m != primaryMuscleGroup)
        .toSet()
        .toList(growable: false);

    await _db.into(_db.exercises).insert(
          ExercisesCompanion.insert(
            id: Value(id),
            name: name.trim(),
            equipmentCategory: equipmentCategory,
            primaryMuscleGroup: primaryMuscleGroup,
            secondaryMuscleGroups: Value(sanitizedSecondary),
            muscleSizeCategory: resolvedMuscleSize,
            exerciseType: exerciseType,
            defaultWorkingRestSeconds: Value(defaultWorkingRestSeconds),
            isCustom: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncStatus: Value(SyncStatus.pendingPush),
          ),
        );
    return id;
  }

  /// Updates an existing exercise and marks `syncStatus = SyncStatus.pendingPush`.
  Future<void> updateExercise({
    required String id,
    required String name,
    required EquipmentCategory equipmentCategory,
    required MuscleGroup primaryMuscleGroup,
    List<MuscleGroup> secondaryMuscleGroups = const [],
    MuscleSizeCategory? muscleSizeCategoryOverride,
    required ExerciseType exerciseType,
    int? defaultWorkingRestSeconds,
  }) async {
    final now = DateTime.now().toUtc();
    final resolvedMuscleSize =
        muscleSizeCategoryOverride ?? primaryMuscleGroup.defaultSizeCategory;
    final sanitizedSecondary = secondaryMuscleGroups
        .where((m) => m != primaryMuscleGroup)
        .toSet()
        .toList(growable: false);

    await (_db.update(_db.exercises)
          ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull()))
        .write(
      ExercisesCompanion(
        name: Value(name.trim()),
        equipmentCategory: Value(equipmentCategory),
        primaryMuscleGroup: Value(primaryMuscleGroup),
        secondaryMuscleGroups: Value(sanitizedSecondary),
        muscleSizeCategory: Value(resolvedMuscleSize),
        exerciseType: Value(exerciseType),
        defaultWorkingRestSeconds: Value(defaultWorkingRestSeconds),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingPush),
      ),
    );
  }

  /// Soft-deletes an exercise (`deletedAt = now`, `syncStatus = SyncStatus.pendingDelete`).
  Future<void> softDeleteExercise(String id) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.exercises)
          ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull()))
        .write(
      ExercisesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingDelete),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EXERCISE MEDIA (SCOPED PER GYM MACHINE, WITH STRICT 4 PHOTOS & 3 VIDEOS LIMIT)
  // ---------------------------------------------------------------------------

  Expression<bool> _mediaScopePredicate(
    $ExerciseMediaTable tbl, {
    required String exerciseId,
    required String? gymMachineId,
  }) {
    final base = tbl.exerciseId.equals(exerciseId) & tbl.deletedAt.isNull();
    if (gymMachineId != null && gymMachineId.isNotEmpty) {
      return base & tbl.gymMachineId.equals(gymMachineId);
    }
    return base & tbl.gymMachineId.isNull();
  }

  /// Watches all active (non-deleted) media attachments for [exerciseId]
  /// and specific [gymMachineId] (or general exercise media if [gymMachineId] is null).
  Stream<List<ExerciseMediaData>> watchMediaForExercise(
    String exerciseId, {
    String? gymMachineId,
  }) {
    final query = _db.select(_db.exerciseMedia)
      ..where(
        (tbl) => _mediaScopePredicate(
          tbl,
          exerciseId: exerciseId,
          gymMachineId: gymMachineId,
        ),
      )
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.sortOrder),
        (tbl) => OrderingTerm.asc(tbl.createdAt),
      ]);
    return query.watch();
  }

  /// Validates that the machine/exercise has not reached the active limit for [mediaType]
  /// (4 photos or 3 videos) before picking/compressing media.
  Future<void> ensureCanAddMedia({
    required String exerciseId,
    String? gymMachineId,
    required MediaType mediaType,
  }) async {
    final activeList = await (_db.select(_db.exerciseMedia)
          ..where(
            (tbl) =>
                _mediaScopePredicate(
                  tbl,
                  exerciseId: exerciseId,
                  gymMachineId: gymMachineId,
                ) &
                tbl.mediaType.equals(mediaType.name),
          ))
        .get();

    final maxAllowed = mediaType == MediaType.photo
        ? maxPhotosPerExercise
        : maxVideosPerExercise;

    if (activeList.length >= maxAllowed) {
      final label = mediaType == MediaType.photo ? 'foto' : 'video';
      throw ExerciseMediaLimitException(
        'Batas maksimal $maxAllowed $label untuk alat/gerakan ini telah tercapai. '
        'Hapus salah satu $label terlebih dahulu.',
      );
    }
  }

  /// Inserts a compressed photo or video attachment for [exerciseId] and [gymMachineId]
  /// after enforcing the strict 4-photo / 3-video active limit inside a transaction.
  Future<String> addExerciseMedia({
    required String exerciseId,
    String? gymMachineId,
    required MediaType mediaType,
    required String localPath,
    String? thumbnailLocalPath,
    required int fileSizeBytes,
    int? durationSeconds,
  }) async {
    return _db.transaction(() async {
      final activeOfType = await (_db.select(_db.exerciseMedia)
            ..where(
              (tbl) =>
                  _mediaScopePredicate(
                    tbl,
                    exerciseId: exerciseId,
                    gymMachineId: gymMachineId,
                  ) &
                  tbl.mediaType.equals(mediaType.name),
            )
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
          .get();

      final maxAllowed = mediaType == MediaType.photo
          ? maxPhotosPerExercise
          : maxVideosPerExercise;

      if (activeOfType.length >= maxAllowed) {
        final label = mediaType == MediaType.photo ? 'foto' : 'video';
        throw ExerciseMediaLimitException(
          'Batas maksimal $maxAllowed $label untuk alat/gerakan ini telah tercapai. '
          'Hapus salah satu $label terlebih dahulu.',
        );
      }

      final nextSortOrder = activeOfType.isEmpty
          ? 0
          : activeOfType
                  .map((m) => m.sortOrder)
                  .reduce((a, b) => a > b ? a : b) +
              1;

      final now = DateTime.now().toUtc();
      final id = _uuid.v4();

      await _db.into(_db.exerciseMedia).insert(
            ExerciseMediaCompanion.insert(
              id: Value(id),
              exerciseId: exerciseId,
              gymMachineId: Value(
                gymMachineId != null && gymMachineId.isNotEmpty
                    ? gymMachineId
                    : null,
              ),
              mediaType: mediaType,
              sortOrder: Value(nextSortOrder),
              localPath: localPath,
              thumbnailLocalPath: Value(thumbnailLocalPath),
              fileSizeBytes: fileSizeBytes,
              durationSeconds: Value(durationSeconds),
              mediaSyncStatus: const Value(MediaSyncStatus.local_only),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: Value(SyncStatus.pendingPush),
            ),
          );

      return id;
    });
  }

  /// Soft-deletes an [ExerciseMediaData] record in SQLite and deletes its
  /// physical `.webp`/`.mp4` file and thumbnail from local storage.
  Future<void> softDeleteExerciseMedia(String mediaId) async {
    final existing = await (_db.select(_db.exerciseMedia)
          ..where((tbl) => tbl.id.equals(mediaId) & tbl.deletedAt.isNull()))
        .getSingleOrNull();

    if (existing == null) return;

    final now = DateTime.now().toUtc();
    await (_db.update(_db.exerciseMedia)
          ..where((tbl) => tbl.id.equals(mediaId) & tbl.deletedAt.isNull()))
        .write(
      ExerciseMediaCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingDelete),
      ),
    );

    await _mediaCompressionService.deleteLocalMediaFile(
      localPath: existing.localPath,
      thumbnailLocalPath: existing.thumbnailLocalPath,
    );
  }
}

@Riverpod(keepAlive: true)
ExerciseLibraryRepository exerciseLibraryRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final mediaService = ref.watch(mediaCompressionServiceProvider);
  return ExerciseLibraryRepository(db, mediaService);
}
