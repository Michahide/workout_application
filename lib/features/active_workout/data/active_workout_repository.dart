import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../../../core/database/syncable_table_mixin.dart';
import '../../../core/database/tables.dart';
import '../../settings/data/app_settings_repository.dart';
import '../../workout_plans/data/workout_plan_repository.dart';

part 'active_workout_repository.g.dart';

/// Historical performance data for a single set number from the last session.
class PreviousSetPerformance {
  const PreviousSetPerformance({
    required this.setNumber,
    required this.setType,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.distanceMeters,
    this.rpe,
    required this.assistanceType,
    this.actualRestSeconds,
    this.weightUnit = WeightUnit.KG,
    this.isFromOtherGym = false,
    this.sourceGymName,
  });

  final int setNumber;
  final SetType setType;
  final double? weight;
  final int? reps;
  final int? durationSeconds;
  final double? distanceMeters;
  final double? rpe;
  final AssistanceType assistanceType;
  final int? actualRestSeconds;
  final WeightUnit weightUnit;
  final bool isFromOtherGym;
  final String? sourceGymName;

  /// Formats inline summary, e.g. `80kg x 10 @ RPE 8.5 | Rest: 2m 10s (Other Gym)`.
  String formatInline(ExerciseType exerciseType) {
    final parts = <String>[];
    final unitSuffix = switch (weightUnit) {
      WeightUnit.KG => 'kg',
      WeightUnit.LBS => 'lbs',
      WeightUnit.STACK_NUMBER => 'stk',
    };

    String formatNum(double val) {
      return val == val.roundToDouble()
          ? val.toInt().toString()
          : val.toStringAsFixed(1);
    }

    switch (exerciseType) {
      case ExerciseType.weight_reps:
      case ExerciseType.weighted_bodyweight:
      case ExerciseType.assisted_bodyweight:
        if (weight != null && reps != null) {
          final prefix = exerciseType == ExerciseType.assisted_bodyweight
              ? '-'
              : exerciseType == ExerciseType.weighted_bodyweight
                  ? '+'
                  : '';
          parts.add('$prefix${formatNum(weight!)}$unitSuffix × $reps');
        } else if (reps != null) {
          parts.add('$reps reps');
        }
      case ExerciseType.bodyweight_reps:
        if (reps != null) {
          parts.add('BW × $reps');
        }
      case ExerciseType.duration:
        if (durationSeconds != null) {
          parts.add(formatCompactDuration(durationSeconds!));
        }
      case ExerciseType.duration_weight:
        if (weight != null && durationSeconds != null) {
          parts.add(
            '${formatNum(weight!)}$unitSuffix × ${formatCompactDuration(durationSeconds!)}',
          );
        }
      case ExerciseType.distance_duration:
        if (distanceMeters != null && durationSeconds != null) {
          parts.add(
            '${formatNum(distanceMeters!)}m / ${formatCompactDuration(durationSeconds!)}',
          );
        }
      case ExerciseType.weight_distance:
        if (weight != null && distanceMeters != null) {
          parts.add(
            '${formatNum(weight!)}$unitSuffix × ${formatNum(distanceMeters!)}m',
          );
        }
    }

    if (rpe != null) {
      parts.add('@ RPE ${formatNum(rpe!)}');
    }
    if (actualRestSeconds != null && actualRestSeconds! > 0) {
      parts.add('Rest: ${formatCompactDuration(actualRestSeconds!)}');
    }
    if (isFromOtherGym) {
      parts.add('(Other Gym)');
    }

    return parts.isEmpty ? '-' : parts.join(' • ');
  }
}

/// Collection of previous set performances keyed by `setNumber` for an exercise/machine.
class PreviousExercisePerformance {
  const PreviousExercisePerformance({
    required this.bySetNumber,
    this.isFromOtherGym = false,
    this.sourceGymName,
  });

  static const empty = PreviousExercisePerformance(bySetNumber: {});

  final Map<int, PreviousSetPerformance> bySetNumber;
  final bool isFromOtherGym;
  final String? sourceGymName;

  PreviousSetPerformance? forSet(int setNumber) => bySetNumber[setNumber];
}

/// Rich bundle for a single exercise inside an active workout session.
class ActiveSessionExerciseBundle {
  const ActiveSessionExerciseBundle({
    required this.sessionExercise,
    required this.exercise,
    this.selectedMachine,
    required this.availableMachinesAtGym,
    this.supersetBadge,
    required this.sets,
  });

  final WorkoutSessionExercise sessionExercise;
  final Exercise exercise;
  final GymMachine? selectedMachine;
  final List<GymMachine> availableMachinesAtGym;
  final String? supersetBadge;
  final List<WorkoutSet> sets;
}

/// Complete crash-proof active workout session state hydrated from Drift.
class ActiveWorkoutSessionDetails {
  const ActiveWorkoutSessionDetails({
    required this.session,
    this.workoutPlan,
    this.gymLocation,
    required this.exercises,
  });

  final WorkoutSession session;
  final WorkoutPlan? workoutPlan;
  final GymLocation? gymLocation;
  final List<ActiveSessionExerciseBundle> exercises;

  int get completedSetsCount => exercises.fold(
        0,
        (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length,
      );

  int get totalSetsCount =>
      exercises.fold(0, (sum, ex) => sum + ex.sets.length);
}

/// Offline-first repository for managing active & historical workout sessions,
/// per-gym machine mapping, and previous performance queries.
class ActiveWorkoutRepository {
  ActiveWorkoutRepository(this._db, this._settingsRepo, this._planRepo);

  final AppDatabase _db;
  final AppSettingsRepository _settingsRepo;
  final WorkoutPlanRepository _planRepo;

  static const _uuid = Uuid();

  // ---------------------------------------------------------------------------
  // CRASH-PROOF ACTIVE SESSION DETECTION & STREAMING
  // ---------------------------------------------------------------------------

  /// Watches the currently active workout session (`completedAt IS NULL AND deletedAt IS NULL`).
  Stream<WorkoutSession?> watchActiveSession() {
    final query = _db.select(_db.workoutSessions)
      ..where((tbl) => tbl.completedAt.isNull() & tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  /// Watches the full [ActiveWorkoutSessionDetails] hierarchy so any edit to a set,
  /// machine, or exercise immediately updates the UI and survives app restarts.
  Stream<ActiveWorkoutSessionDetails?> watchActiveSessionDetails() {
    return watchActiveSession().asyncExpand((session) {
      if (session == null) {
        return Stream.value(null);
      }

      // Watch session exercises, sets, and gym machines reactively
      final sessionExercisesStream = (_db.select(_db.workoutSessionExercises)
            ..where(
              (tbl) =>
                  tbl.workoutSessionId.equals(session.id) &
                  tbl.deletedAt.isNull(),
            )
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
          .watch();

      final setsStream = (_db.select(_db.workoutSets)
            ..where((tbl) => tbl.deletedAt.isNull())
            ..orderBy([
              (tbl) => OrderingTerm.asc(tbl.setNumber),
              (tbl) => OrderingTerm.asc(tbl.createdAt),
            ]))
          .watch();

      final machinesStream = (_db.select(_db.gymMachines)
            ..where((tbl) => tbl.deletedAt.isNull()))
          .watch();

      return sessionExercisesStream.asyncExpand((sessionExercises) {
        return setsStream.asyncExpand((allSets) {
          return machinesStream.asyncMap((allMachines) async {
            return _buildSessionDetails(
              session: session,
              sessionExercises: sessionExercises,
              allSets: allSets,
              allMachines: allMachines,
            );
          });
        });
      });
    });
  }

  Future<ActiveWorkoutSessionDetails> _buildSessionDetails({
    required WorkoutSession session,
    required List<WorkoutSessionExercise> sessionExercises,
    required List<WorkoutSet> allSets,
    required List<GymMachine> allMachines,
  }) async {
    WorkoutPlan? plan;
    if (session.workoutPlanId != null) {
      plan = await (_db.select(_db.workoutPlans)
            ..where(
              (tbl) =>
                  tbl.id.equals(session.workoutPlanId!) &
                  tbl.deletedAt.isNull(),
            ))
          .getSingleOrNull();
    }

    GymLocation? gym;
    if (session.gymLocationId != null) {
      gym = await (_db.select(_db.gymLocations)
            ..where(
              (tbl) =>
                  tbl.id.equals(session.gymLocationId!) &
                  tbl.deletedAt.isNull(),
            ))
          .getSingleOrNull();
    }

    final exerciseIds =
        sessionExercises.map((e) => e.exerciseId).toSet().toList();
    final exerciseRows = exerciseIds.isEmpty
        ? const <Exercise>[]
        : await (_db.select(_db.exercises)
              ..where((tbl) => tbl.id.isIn(exerciseIds)))
            .get();
    final exerciseMap = {for (final e in exerciseRows) e.id: e};
    final machineMap = {for (final m in allMachines) m.id: m};

    final groupIds = sessionExercises
        .map((se) => se.supersetGroupId)
        .toList(growable: false);
    final supersetBadges = computeSupersetBadges(groupIds);

    final bundles = <ActiveSessionExerciseBundle>[];
    for (var i = 0; i < sessionExercises.length; i++) {
      final se = sessionExercises[i];
      final ex = exerciseMap[se.exerciseId];
      if (ex == null) continue;

      final availableMachines = allMachines.where((m) {
        if (m.exerciseId != ex.id) return false;
        if (session.gymLocationId == null) {
          return m.gymLocationId == null;
        }
        return m.gymLocationId == session.gymLocationId ||
            m.gymLocationId == null;
      }).toList(growable: false);

      final setsForExercise = allSets
          .where((s) => s.workoutSessionExerciseId == se.id)
          .toList(growable: false);

      bundles.add(
        ActiveSessionExerciseBundle(
          sessionExercise: se,
          exercise: ex,
          selectedMachine:
              se.gymMachineId != null ? machineMap[se.gymMachineId!] : null,
          availableMachinesAtGym: availableMachines,
          supersetBadge: supersetBadges[i],
          sets: setsForExercise,
        ),
      );
    }

    return ActiveWorkoutSessionDetails(
      session: session,
      workoutPlan: plan,
      gymLocation: gym,
      exercises: bundles,
    );
  }

  // ---------------------------------------------------------------------------
  // START WORKOUT SESSION & AUTO MACHINE MAPPING
  // ---------------------------------------------------------------------------

  /// Starts a new active workout session (from a [workoutPlanId] or an Empty Workout)
  /// at [gymLocationId], automatically mapping exercises to registered machines at that gym.
  Future<String> startWorkoutSession({
    required String gymLocationId,
    String? workoutPlanId,
  }) async {
    final existingActive = await (_db.select(_db.workoutSessions)
          ..where((tbl) => tbl.completedAt.isNull() & tbl.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (existingActive != null) {
      return existingActive.id;
    }

    final settings = await _settingsRepo.getSettings();
    final now = DateTime.now().toUtc();
    final sessionId = _uuid.v4();

    await _db.transaction(() async {
      await _db.into(_db.workoutSessions).insert(
            WorkoutSessionsCompanion.insert(
              id: Value(sessionId),
              workoutPlanId: Value(workoutPlanId),
              gymLocationId: Value(gymLocationId),
              startedAt: now,
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: Value(SyncStatus.pendingPush),
            ),
          );

      if (workoutPlanId != null) {
        final planWithExercises =
            await _planRepo.getPlanWithExercises(workoutPlanId);
        if (planWithExercises != null) {
          for (var i = 0; i < planWithExercises.exercises.length; i++) {
            final item = planWithExercises.exercises[i];
            final pe = item.planExercise;
            final ex = item.exercise;

            final selectedMachineId = await _resolveAutoMachineId(
              gymLocationId: gymLocationId,
              exerciseId: ex.id,
              preferredMachineId: pe.defaultGymMachineId,
            );

            final seId = _uuid.v4();
            await _db.into(_db.workoutSessionExercises).insert(
                  WorkoutSessionExercisesCompanion.insert(
                    id: Value(seId),
                    workoutSessionId: sessionId,
                    exerciseId: ex.id,
                    gymMachineId: Value(selectedMachineId),
                    sortOrder: Value(i),
                    supersetGroupId: Value(pe.supersetGroupId),
                    createdAt: Value(now),
                    updatedAt: Value(now),
                    syncStatus: Value(SyncStatus.pendingPush),
                  ),
                );

            final targetRest = AppSettingsRepository.resolveTargetRestSeconds(
              settings: settings,
              setType: SetType.normal,
              muscleSizeCategory: ex.muscleSizeCategory,
              customWorkingRestSeconds:
                  pe.targetRestSeconds ?? ex.defaultWorkingRestSeconds,
            );

            // Pre-populate sets from previous performance if available
            final prevPerf = await getPreviousPerformanceForMachine(
              exerciseId: ex.id,
              gymMachineId: selectedMachineId,
              excludeSessionId: sessionId,
            );

            final setsCount = pe.targetSets.clamp(1, 20);
            for (var setNum = 1; setNum <= setsCount; setNum++) {
              final prevSet = prevPerf.forSet(setNum);
              await _db.into(_db.workoutSets).insert(
                    WorkoutSetsCompanion.insert(
                      id: Value(_uuid.v4()),
                      workoutSessionExerciseId: seId,
                      setNumber: setNum,
                      setType: const Value(SetType.normal),
                      weight: Value(prevSet?.weight),
                      reps: Value(pe.targetReps ?? prevSet?.reps),
                      assistanceType: const Value(AssistanceType.solo),
                      targetRestSeconds: Value(targetRest),
                      isCompleted: const Value(false),
                      createdAt: Value(now),
                      updatedAt: Value(now),
                      syncStatus: Value(SyncStatus.pendingPush),
                    ),
                  );
            }
          }
        }
      }
    });

    return sessionId;
  }

  /// Finds the appropriate [GymMachine] for `(gymLocationId, exerciseId)`.
  /// Prioritizes machines registered specifically at [gymLocationId], falling back
  /// to global equipment (`gymLocationId IS NULL`).
  Future<String?> _resolveAutoMachineId({
    required String? gymLocationId,
    required String exerciseId,
    String? preferredMachineId,
  }) async {
    final candidates = await (_db.select(_db.gymMachines)
          ..where(
            (tbl) =>
                tbl.exerciseId.equals(exerciseId) & tbl.deletedAt.isNull(),
          ))
        .get();

    if (candidates.isEmpty) return null;

    if (gymLocationId != null) {
      final atGym = candidates
          .where((m) => m.gymLocationId == gymLocationId)
          .toList(growable: false);
      if (atGym.length == 1) {
        return atGym.first.id;
      }
      if (atGym.length > 1) {
        if (preferredMachineId != null &&
            atGym.any((m) => m.id == preferredMachineId)) {
          return preferredMachineId;
        }
        return atGym.first.id;
      }
    }

    final globalMachines = candidates
        .where((m) => m.gymLocationId == null)
        .toList(growable: false);
    if (globalMachines.isNotEmpty) {
      return globalMachines.first.id;
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // INLINE PREVIOUS PERFORMANCE PER GYM MACHINE (WITH OTHER GYM FALLBACK)
  // ---------------------------------------------------------------------------

  /// Queries the last completed workout session sets for [exerciseId] and [gymMachineId].
  ///
  /// - Primary lookup: strictly filters by `exerciseId` AND `gymMachineId` from the most
  ///   recent completed session (`isFromOtherGym = false`).
  /// - Fallback lookup: if no history exists on that machine at this gym, fetches the
  ///   most recent completed session for `exerciseId` from any gym and tags it with
  ///   `isFromOtherGym = true`.
  Future<PreviousExercisePerformance> getPreviousPerformanceForMachine({
    required String exerciseId,
    required String? gymMachineId,
    String? excludeSessionId,
  }) async {
    if (gymMachineId != null && gymMachineId.isNotEmpty) {
      final exactMatch = await _queryLastCompletedSessionSets(
        exerciseId: exerciseId,
        gymMachineId: gymMachineId,
        excludeSessionId: excludeSessionId,
        isFromOtherGym: false,
      );
      if (exactMatch != null) {
        return exactMatch;
      }
    }

    final fallbackMatch = await _queryLastCompletedSessionSets(
      exerciseId: exerciseId,
      gymMachineId: null,
      excludeSessionId: excludeSessionId,
      isFromOtherGym: true,
    );

    return fallbackMatch ?? PreviousExercisePerformance.empty;
  }

  Future<PreviousExercisePerformance?> _queryLastCompletedSessionSets({
    required String exerciseId,
    required String? gymMachineId,
    String? excludeSessionId,
    required bool isFromOtherGym,
  }) async {
    final joinQuery = _db.select(_db.workoutSessionExercises).join([
      innerJoin(
        _db.workoutSessions,
        _db.workoutSessions.id.equalsExp(
              _db.workoutSessionExercises.workoutSessionId,
            ) &
            _db.workoutSessions.deletedAt.isNull(),
      ),
      leftOuterJoin(
        _db.gymMachines,
        _db.gymMachines.id.equalsExp(_db.workoutSessionExercises.gymMachineId),
      ),
      leftOuterJoin(
        _db.gymLocations,
        _db.gymLocations.id.equalsExp(_db.workoutSessions.gymLocationId),
      ),
    ]);

    Expression<bool> predicate =
        _db.workoutSessionExercises.exerciseId.equals(exerciseId) &
            _db.workoutSessionExercises.deletedAt.isNull();

    if (gymMachineId != null) {
      predicate = predicate &
          _db.workoutSessionExercises.gymMachineId.equals(gymMachineId);
    }

    if (excludeSessionId != null) {
      predicate = predicate &
          _db.workoutSessionExercises.workoutSessionId
              .isNotValue(excludeSessionId);
    }

    joinQuery
      ..where(predicate)
      ..orderBy([
        OrderingTerm.desc(_db.workoutSessions.completedAt),
        OrderingTerm.desc(_db.workoutSessions.startedAt),
      ]);

    final candidateRows = await joinQuery.get();
    for (final row in candidateRows) {
      final se = row.readTable(_db.workoutSessionExercises);
      final machine = row.readTableOrNull(_db.gymMachines);
      final gym = row.readTableOrNull(_db.gymLocations);

      final completedSets = await (_db.select(_db.workoutSets)
            ..where(
              (tbl) =>
                  tbl.workoutSessionExerciseId.equals(se.id) &
                  tbl.isCompleted.equals(true) &
                  tbl.deletedAt.isNull(),
            )
            ..orderBy([
              (tbl) => OrderingTerm.asc(tbl.setNumber),
              (tbl) => OrderingTerm.asc(tbl.createdAt),
            ]))
          .get();

      if (completedSets.isEmpty) continue;

      final bySetNum = <int, PreviousSetPerformance>{};
      for (final s in completedSets) {
        // Keep top-level sets or first set per setNumber
        bySetNum.putIfAbsent(
          s.setNumber,
          () => PreviousSetPerformance(
            setNumber: s.setNumber,
            setType: s.setType,
            weight: s.weight,
            reps: s.reps,
            durationSeconds: s.durationSeconds,
            distanceMeters: s.distanceMeters,
            rpe: s.rpe,
            assistanceType: s.assistanceType,
            actualRestSeconds: s.actualRestSeconds,
            weightUnit: machine?.weightUnit ?? WeightUnit.KG,
            isFromOtherGym: isFromOtherGym,
            sourceGymName: gym?.name,
          ),
        );
      }

      return PreviousExercisePerformance(
        bySetNumber: bySetNum,
        isFromOtherGym: isFromOtherGym,
        sourceGymName: gym?.name,
      );
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // ACTIVE WORKOUT EXERCISES, MACHINES, & SETS MUTATIONS (IMMEDIATE PERSISTENCE)
  // ---------------------------------------------------------------------------

  /// Quick-registers a new [GymMachine] at the current gym and assigns it to
  /// [sessionExerciseId] in a single transaction without leaving the Active Workout screen.
  Future<String> quickRegisterAndAssignMachine({
    required String sessionExerciseId,
    required String exerciseId,
    required String? gymLocationId,
    required String brandName,
    required WeightUnit weightUnit,
    String? pinnedNotes,
  }) async {
    final now = DateTime.now().toUtc();
    final machineId = _uuid.v4();

    await _db.transaction(() async {
      await _db.into(_db.gymMachines).insert(
            GymMachinesCompanion.insert(
              id: Value(machineId),
              gymLocationId: Value(gymLocationId),
              exerciseId: exerciseId,
              brandName: Value(_nullIfEmpty(brandName)),
              weightUnit: Value(weightUnit),
              pinnedNotes: Value(_nullIfEmpty(pinnedNotes)),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: Value(SyncStatus.pendingPush),
            ),
          );

      await (_db.update(_db.workoutSessionExercises)
            ..where(
              (tbl) => tbl.id.equals(sessionExerciseId) & tbl.deletedAt.isNull(),
            ))
          .write(
        WorkoutSessionExercisesCompanion(
          gymMachineId: Value(machineId),
          updatedAt: Value(now),
          syncStatus: Value(SyncStatus.pendingPush),
        ),
      );
    });

    return machineId;
  }

  /// Switches the assigned [gymMachineId] for an exercise in the active session.
  Future<void> assignMachineToSessionExercise({
    required String sessionExerciseId,
    required String? gymMachineId,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.workoutSessionExercises)
          ..where(
            (tbl) => tbl.id.equals(sessionExerciseId) & tbl.deletedAt.isNull(),
          ))
        .write(
      WorkoutSessionExercisesCompanion(
        gymMachineId: Value(gymMachineId),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingPush),
      ),
    );
  }

  /// Adds a new exercise to the currently active workout session and creates 3 initial sets.
  Future<String> addExerciseToSession({
    required String workoutSessionId,
    required String exerciseId,
    required String? gymLocationId,
    String? supersetGroupId,
  }) async {
    final now = DateTime.now().toUtc();
    final settings = await _settingsRepo.getSettings();
    final exercise = await (_db.select(_db.exercises)
          ..where((tbl) => tbl.id.equals(exerciseId)))
        .getSingle();

    final existingExercises = await (_db.select(_db.workoutSessionExercises)
          ..where(
            (tbl) =>
                tbl.workoutSessionId.equals(workoutSessionId) &
                tbl.deletedAt.isNull(),
          ))
        .get();

    final nextSortOrder = existingExercises.isEmpty
        ? 0
        : existingExercises
                .map((e) => e.sortOrder)
                .reduce((a, b) => a > b ? a : b) +
            1;

    final autoMachineId = await _resolveAutoMachineId(
      gymLocationId: gymLocationId,
      exerciseId: exerciseId,
    );

    final seId = _uuid.v4();
    final targetRest = AppSettingsRepository.resolveTargetRestSeconds(
      settings: settings,
      setType: SetType.normal,
      muscleSizeCategory: exercise.muscleSizeCategory,
      customWorkingRestSeconds: exercise.defaultWorkingRestSeconds,
    );

    await _db.transaction(() async {
      await _db.into(_db.workoutSessionExercises).insert(
            WorkoutSessionExercisesCompanion.insert(
              id: Value(seId),
              workoutSessionId: workoutSessionId,
              exerciseId: exerciseId,
              gymMachineId: Value(autoMachineId),
              sortOrder: Value(nextSortOrder),
              supersetGroupId: Value(_nullIfEmpty(supersetGroupId)),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: Value(SyncStatus.pendingPush),
            ),
          );

      for (var setNum = 1; setNum <= 3; setNum++) {
        await _db.into(_db.workoutSets).insert(
              WorkoutSetsCompanion.insert(
                id: Value(_uuid.v4()),
                workoutSessionExerciseId: seId,
                setNumber: setNum,
                setType: const Value(SetType.normal),
                assistanceType: const Value(AssistanceType.solo),
                targetRestSeconds: Value(targetRest),
                isCompleted: const Value(false),
                createdAt: Value(now),
                updatedAt: Value(now),
                syncStatus: Value(SyncStatus.pendingPush),
              ),
            );
      }
    });

    return seId;
  }

  /// Soft-deletes an exercise and its sets from the active session.
  Future<void> removeExerciseFromSession(String sessionExerciseId) async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.workoutSessionExercises)
            ..where((tbl) => tbl.id.equals(sessionExerciseId)))
          .write(
        WorkoutSessionExercisesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: Value(SyncStatus.pendingDelete),
        ),
      );

      await (_db.update(_db.workoutSets)
            ..where(
              (tbl) => tbl.workoutSessionExerciseId.equals(sessionExerciseId),
            ))
          .write(
        WorkoutSetsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: Value(SyncStatus.pendingDelete),
        ),
      );
    });
  }

  /// Adds a new set (or a sub-drop set when [parentSetId] is provided) to [sessionExerciseId].
  Future<String> addSet({
    required String sessionExerciseId,
    required MuscleSizeCategory muscleSizeCategory,
    int? customExerciseRestSeconds,
    SetType setType = SetType.normal,
    String? parentSetId,
    int? parentSetNumber,
  }) async {
    final now = DateTime.now().toUtc();
    final settings = await _settingsRepo.getSettings();
    final existingSets = await (_db.select(_db.workoutSets)
          ..where(
            (tbl) =>
                tbl.workoutSessionExerciseId.equals(sessionExerciseId) &
                tbl.deletedAt.isNull(),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.setNumber)]))
        .get();

    final nextSetNumber = parentSetNumber ??
        (existingSets.isEmpty
            ? 1
            : existingSets
                    .map((s) => s.setNumber)
                    .reduce((a, b) => a > b ? a : b) +
                1);

    final lastSet = existingSets.isNotEmpty ? existingSets.last : null;
    final targetRest = AppSettingsRepository.resolveTargetRestSeconds(
      settings: settings,
      setType: setType,
      muscleSizeCategory: muscleSizeCategory,
      customWorkingRestSeconds: customExerciseRestSeconds,
    );

    final setId = _uuid.v4();
    await _db.into(_db.workoutSets).insert(
          WorkoutSetsCompanion.insert(
            id: Value(setId),
            workoutSessionExerciseId: sessionExerciseId,
            setNumber: nextSetNumber,
            parentSetId: Value(parentSetId),
            setType: Value(setType),
            weight: Value(lastSet?.weight),
            reps: Value(lastSet?.reps),
            durationSeconds: Value(lastSet?.durationSeconds),
            distanceMeters: Value(lastSet?.distanceMeters),
            assistanceType: const Value(AssistanceType.solo),
            targetRestSeconds: Value(targetRest),
            isCompleted: const Value(false),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncStatus: Value(SyncStatus.pendingPush),
          ),
        );

    return setId;
  }

  /// Immediately persists any edit to a [WorkoutSet] row for crash-proof recovery.
  Future<void> updateSet({
    required String setId,
    SetType? setType,
    Value<double?> weight = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<double?> distanceMeters = const Value.absent(),
    Value<double?> rpe = const Value.absent(),
    AssistanceType? assistanceType,
    Value<int?> targetRestSeconds = const Value.absent(),
    Value<int?> actualRestSeconds = const Value.absent(),
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.workoutSets)
          ..where((tbl) => tbl.id.equals(setId) & tbl.deletedAt.isNull()))
        .write(
      WorkoutSetsCompanion(
        setType: setType != null ? Value(setType) : const Value.absent(),
        weight: weight,
        reps: reps,
        durationSeconds: durationSeconds,
        distanceMeters: distanceMeters,
        rpe: rpe,
        assistanceType: assistanceType != null
            ? Value(assistanceType)
            : const Value.absent(),
        targetRestSeconds: targetRestSeconds,
        actualRestSeconds: actualRestSeconds,
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingPush),
      ),
    );
  }

  /// Marks a set as completed or uncompleted, recording `completedAt`,
  /// `targetRestSeconds`, and `actualRestSeconds` elapsed since the previous set.
  Future<void> completeSet({
    required String setId,
    required bool isCompleted,
    int? targetRestSeconds,
    int? actualRestSeconds,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.workoutSets)
          ..where((tbl) => tbl.id.equals(setId) & tbl.deletedAt.isNull()))
        .write(
      WorkoutSetsCompanion(
        isCompleted: Value(isCompleted),
        completedAt: Value(isCompleted ? now : null),
        targetRestSeconds: targetRestSeconds != null
            ? Value(targetRestSeconds)
            : const Value.absent(),
        actualRestSeconds: isCompleted && actualRestSeconds != null
            ? Value(actualRestSeconds)
            : const Value.absent(),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingPush),
      ),
    );
  }

  /// Soft-deletes a set and any sub-drop sets linked to it.
  Future<void> softDeleteSet(String setId) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.workoutSets)
          ..where(
            (tbl) =>
                (tbl.id.equals(setId) | tbl.parentSetId.equals(setId)) &
                tbl.deletedAt.isNull(),
          ))
        .write(
      WorkoutSetsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingDelete),
      ),
    );
  }

  /// Marks the active workout session as completed (`completedAt = now`).
  Future<void> finishWorkoutSession({
    required String sessionId,
    String? sessionNotes,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.workoutSessions)
          ..where((tbl) => tbl.id.equals(sessionId) & tbl.deletedAt.isNull()))
        .write(
      WorkoutSessionsCompanion(
        completedAt: Value(now),
        sessionNotes: Value(_nullIfEmpty(sessionNotes)),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingPush),
      ),
    );
  }

  /// Soft-deletes an active workout session if the user chooses to discard it.
  Future<void> discardWorkoutSession(String sessionId) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.workoutSessions)
          ..where((tbl) => tbl.id.equals(sessionId) & tbl.deletedAt.isNull()))
        .write(
      WorkoutSessionsCompanion(
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
ActiveWorkoutRepository activeWorkoutRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final settingsRepo = ref.watch(appSettingsRepositoryProvider);
  final planRepo = ref.watch(workoutPlanRepositoryProvider);
  return ActiveWorkoutRepository(db, settingsRepo, planRepo);
}

final activeWorkoutSessionStreamProvider =
    StreamProvider.autoDispose<ActiveWorkoutSessionDetails?>((ref) {
      final repo = ref.watch(activeWorkoutRepositoryProvider);
      return repo.watchActiveSessionDetails();
    });

typedef PreviousPerfKey = ({
  String exerciseId,
  String? gymMachineId,
  String? excludeSessionId,
});

final previousExercisePerformanceProvider = FutureProvider.autoDispose
    .family<PreviousExercisePerformance, PreviousPerfKey>((ref, key) {
      final repo = ref.watch(activeWorkoutRepositoryProvider);
      return repo.getPreviousPerformanceForMachine(
        exerciseId: key.exerciseId,
        gymMachineId: key.gymMachineId,
        excludeSessionId: key.excludeSessionId,
      );
    });
