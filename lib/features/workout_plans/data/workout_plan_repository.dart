import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/syncable_table_mixin.dart';

part 'workout_plan_repository.g.dart';

/// Enriched exercise row inside a [WorkoutPlan], including its computed superset label (e.g. `A1`, `A2`).
class WorkoutPlanExerciseWithDetails {
  const WorkoutPlanExerciseWithDetails({
    required this.planExercise,
    required this.exercise,
    this.supersetBadge,
  });

  final WorkoutPlanExercise planExercise;
  final Exercise exercise;

  /// Human-readable superset tag such as `A1`, `A2`, `B1`, or `null` if not in a superset.
  final String? supersetBadge;
}

/// Complete [WorkoutPlan] with its ordered list of active [WorkoutPlanExerciseWithDetails].
class WorkoutPlanWithExercises {
  const WorkoutPlanWithExercises({
    required this.plan,
    required this.exercises,
  });

  final WorkoutPlan plan;
  final List<WorkoutPlanExerciseWithDetails> exercises;
}

/// Draft item used when creating or updating the ordered exercises of a [WorkoutPlan].
class WorkoutPlanExerciseDraft {
  const WorkoutPlanExerciseDraft({
    this.id,
    required this.exerciseId,
    this.defaultGymMachineId,
    this.supersetGroupId,
    this.targetSets = 3,
    this.targetReps = 10,
    this.targetRestSeconds,
  });

  final String? id;
  final String exerciseId;
  final String? defaultGymMachineId;
  final String? supersetGroupId;
  final int targetSets;
  final int? targetReps;
  final int? targetRestSeconds;

  WorkoutPlanExerciseDraft copyWith({
    String? id,
    String? exerciseId,
    String? Function()? defaultGymMachineId,
    String? Function()? supersetGroupId,
    int? targetSets,
    int? Function()? targetReps,
    int? Function()? targetRestSeconds,
  }) {
    return WorkoutPlanExerciseDraft(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      defaultGymMachineId: defaultGymMachineId != null
          ? defaultGymMachineId()
          : this.defaultGymMachineId,
      supersetGroupId: supersetGroupId != null
          ? supersetGroupId()
          : this.supersetGroupId,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps != null ? targetReps() : this.targetReps,
      targetRestSeconds: targetRestSeconds != null
          ? targetRestSeconds()
          : this.targetRestSeconds,
    );
  }
}

/// Helper that computes superset labels (`A1`, `A2`, `B1`, `B2`...) for a list of
/// group IDs in order of appearance.
Map<int, String> computeSupersetBadges(List<String?> groupIds) {
  final groupCounts = <String, int>{};
  for (final gid in groupIds) {
    if (gid != null && gid.isNotEmpty) {
      groupCounts[gid] = (groupCounts[gid] ?? 0) + 1;
    }
  }

  final groupLetterMap = <String, String>{};
  final groupMemberCounter = <String, int>{};
  var nextLetterCode = 'A'.codeUnitAt(0);
  final result = <int, String>{};

  for (var i = 0; i < groupIds.length; i++) {
    final gid = groupIds[i];
    if (gid == null || gid.isEmpty || (groupCounts[gid] ?? 0) < 2) {
      continue;
    }
    final letter = groupLetterMap.putIfAbsent(gid, () {
      final assigned = String.fromCharCode(nextLetterCode);
      nextLetterCode++;
      return assigned;
    });
    final memberIdx = (groupMemberCounter[gid] ?? 0) + 1;
    groupMemberCounter[gid] = memberIdx;
    result[i] = '$letter$memberIdx';
  }

  return result;
}

/// Offline-first repository for managing [WorkoutPlans] and [WorkoutPlanExercises].
class WorkoutPlanRepository {
  WorkoutPlanRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Watches all active (non-deleted) workout plans along with their ordered exercises.
  Stream<List<WorkoutPlanWithExercises>> watchPlansWithExercises() {
    final plansQuery = _db.select(_db.workoutPlans)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);

    final itemsQuery = _db.select(_db.workoutPlanExercises).join([
      innerJoin(
        _db.exercises,
        _db.exercises.id.equalsExp(_db.workoutPlanExercises.exerciseId) &
            _db.exercises.deletedAt.isNull(),
      ),
    ])
      ..where(_db.workoutPlanExercises.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(_db.workoutPlanExercises.sortOrder)]);

    return plansQuery.watch().asyncExpand((plans) {
      return itemsQuery.watch().map((itemRows) {
        final groupedByPlan = <String, List<TypedResult>>{};
        for (final row in itemRows) {
          final pe = row.readTable(_db.workoutPlanExercises);
          groupedByPlan.putIfAbsent(pe.workoutPlanId, () => []).add(row);
        }

        return plans.map((plan) {
          final rows = groupedByPlan[plan.id] ?? const <TypedResult>[];
          final groupIds = rows
              .map(
                (r) => r.readTable(_db.workoutPlanExercises).supersetGroupId,
              )
              .toList(growable: false);
          final badges = computeSupersetBadges(groupIds);

          final enriched = <WorkoutPlanExerciseWithDetails>[];
          for (var i = 0; i < rows.length; i++) {
            final row = rows[i];
            enriched.add(
              WorkoutPlanExerciseWithDetails(
                planExercise: row.readTable(_db.workoutPlanExercises),
                exercise: row.readTable(_db.exercises),
                supersetBadge: badges[i],
              ),
            );
          }

          return WorkoutPlanWithExercises(
            plan: plan,
            exercises: enriched,
          );
        }).toList(growable: false);
      });
    });
  }

  /// Fetches a single active [WorkoutPlanWithExercises] by [planId].
  Future<WorkoutPlanWithExercises?> getPlanWithExercises(String planId) async {
    final plan = await (_db.select(_db.workoutPlans)
          ..where((tbl) => tbl.id.equals(planId) & tbl.deletedAt.isNull()))
        .getSingleOrNull();
    if (plan == null) return null;

    final rows = await (_db.select(_db.workoutPlanExercises).join([
      innerJoin(
        _db.exercises,
        _db.exercises.id.equalsExp(_db.workoutPlanExercises.exerciseId) &
            _db.exercises.deletedAt.isNull(),
      ),
    ])
          ..where(
            _db.workoutPlanExercises.workoutPlanId.equals(planId) &
                _db.workoutPlanExercises.deletedAt.isNull(),
          )
          ..orderBy([OrderingTerm.asc(_db.workoutPlanExercises.sortOrder)]))
        .get();

    final groupIds = rows
        .map((r) => r.readTable(_db.workoutPlanExercises).supersetGroupId)
        .toList(growable: false);
    final badges = computeSupersetBadges(groupIds);

    final enriched = <WorkoutPlanExerciseWithDetails>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      enriched.add(
        WorkoutPlanExerciseWithDetails(
          planExercise: row.readTable(_db.workoutPlanExercises),
          exercise: row.readTable(_db.exercises),
          supersetBadge: badges[i],
        ),
      );
    }

    return WorkoutPlanWithExercises(plan: plan, exercises: enriched);
  }

  /// Creates or updates a [WorkoutPlan] and synchronizes its ordered [WorkoutPlanExerciseDraft] list
  /// using strict soft-deletes for removed items and `SyncStatus.pendingPush` for created/updated items.
  Future<String> saveWorkoutPlan({
    String? existingPlanId,
    required String name,
    String? notes,
    required List<WorkoutPlanExerciseDraft> exerciseDrafts,
  }) async {
    final now = DateTime.now().toUtc();
    final planId = existingPlanId ?? _uuid.v4();

    await _db.transaction(() async {
      if (existingPlanId == null) {
        await _db.into(_db.workoutPlans).insert(
              WorkoutPlansCompanion.insert(
                id: Value(planId),
                name: name.trim(),
                notes: Value(_nullIfEmpty(notes)),
                createdAt: Value(now),
                updatedAt: Value(now),
                syncStatus: Value(SyncStatus.pendingPush),
              ),
            );
      } else {
        await (_db.update(_db.workoutPlans)
              ..where(
                (tbl) => tbl.id.equals(planId) & tbl.deletedAt.isNull(),
              ))
            .write(
          WorkoutPlansCompanion(
            name: Value(name.trim()),
            notes: Value(_nullIfEmpty(notes)),
            updatedAt: Value(now),
            syncStatus: Value(SyncStatus.pendingPush),
          ),
        );
      }

      // Fetch existing active plan exercises
      final existingItems = await (_db.select(_db.workoutPlanExercises)
            ..where(
              (tbl) =>
                  tbl.workoutPlanId.equals(planId) & tbl.deletedAt.isNull(),
            ))
          .get();

      final retainedIds = exerciseDrafts
          .map((d) => d.id)
          .whereType<String>()
          .toSet();

      // Soft-delete any removed exercises
      for (final oldItem in existingItems) {
        if (!retainedIds.contains(oldItem.id)) {
          await (_db.update(_db.workoutPlanExercises)
                ..where((tbl) => tbl.id.equals(oldItem.id)))
              .write(
            WorkoutPlanExercisesCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
              syncStatus: Value(SyncStatus.pendingDelete),
            ),
          );
        }
      }

      // Upsert current ordered exercises
      for (var index = 0; index < exerciseDrafts.length; index++) {
        final draft = exerciseDrafts[index];
        final itemId = draft.id ?? _uuid.v4();
        final exists = existingItems.any((e) => e.id == itemId);

        if (exists) {
          await (_db.update(_db.workoutPlanExercises)
                ..where((tbl) => tbl.id.equals(itemId)))
              .write(
            WorkoutPlanExercisesCompanion(
              exerciseId: Value(draft.exerciseId),
              defaultGymMachineId: Value(draft.defaultGymMachineId),
              sortOrder: Value(index),
              supersetGroupId: Value(_nullIfEmpty(draft.supersetGroupId)),
              targetSets: Value(draft.targetSets.clamp(1, 20)),
              targetReps: Value(draft.targetReps),
              targetRestSeconds: Value(draft.targetRestSeconds),
              updatedAt: Value(now),
              syncStatus: Value(SyncStatus.pendingPush),
            ),
          );
        } else {
          await _db.into(_db.workoutPlanExercises).insert(
                WorkoutPlanExercisesCompanion.insert(
                  id: Value(itemId),
                  workoutPlanId: planId,
                  exerciseId: draft.exerciseId,
                  defaultGymMachineId: Value(draft.defaultGymMachineId),
                  sortOrder: index,
                  supersetGroupId: Value(_nullIfEmpty(draft.supersetGroupId)),
                  targetSets: Value(draft.targetSets.clamp(1, 20)),
                  targetReps: Value(draft.targetReps),
                  targetRestSeconds: Value(draft.targetRestSeconds),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                  syncStatus: Value(SyncStatus.pendingPush),
                ),
              );
        }
      }
    });

    return planId;
  }

  /// Soft-deletes a [WorkoutPlan] and all of its [WorkoutPlanExercises].
  Future<void> softDeleteWorkoutPlan(String planId) async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.workoutPlans)
            ..where((tbl) => tbl.id.equals(planId) & tbl.deletedAt.isNull()))
          .write(
        WorkoutPlansCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: Value(SyncStatus.pendingDelete),
        ),
      );

      await (_db.update(_db.workoutPlanExercises)
            ..where(
              (tbl) =>
                  tbl.workoutPlanId.equals(planId) & tbl.deletedAt.isNull(),
            ))
          .write(
        WorkoutPlanExercisesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: Value(SyncStatus.pendingDelete),
        ),
      );
    });
  }

  String? _nullIfEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

@Riverpod(keepAlive: true)
WorkoutPlanRepository workoutPlanRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return WorkoutPlanRepository(db);
}
