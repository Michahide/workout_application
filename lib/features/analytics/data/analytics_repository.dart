import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/syncable_table_mixin.dart';
import '../../../core/database/table_updates_watcher.dart';
import '../../../core/database/tables.dart';
import '../domain/workout_calculator.dart';

part 'analytics_repository.g.dart';

/// Date range filter options for exercise progression charts.
enum AnalyticsDateRange {
  days30('1M', 30),
  months3('3M', 90),
  months6('6M', 180),
  year1('1Y', 365),
  allTime('ALL', null);

  const AnalyticsDateRange(this.shortLabel, this.daysBack);

  final String shortLabel;
  final int? daysBack;

  DateTime? cutoffDateUtc([DateTime? nowUtc]) {
    if (daysBack == null) return null;
    final anchor = nowUtc ?? DateTime.now().toUtc();
    return anchor.subtract(Duration(days: daysBack!));
  }
}

/// Filter parameters for Exercise PRs and progression series queries.
class AnalyticsFilter {
  const AnalyticsFilter({
    required this.exerciseId,
    this.gymMachineId,
    this.includeAssistedSets = false,
    this.dateRange = AnalyticsDateRange.allTime,
  });

  final String exerciseId;

  /// When non-null, strictly filters sets performed on this specific machine.
  /// When null, aggregates globally across all machines/gyms for [exerciseId].
  final String? gymMachineId;

  /// Default `false` (Solo Mode: only `solo` and `spotted_no_touch` sets).
  /// When `true`, includes `assisted` sets and flags them.
  final bool includeAssistedSets;

  final AnalyticsDateRange dateRange;

  AnalyticsFilter copyWith({
    String? exerciseId,
    String? Function()? gymMachineId,
    bool? includeAssistedSets,
    AnalyticsDateRange? dateRange,
  }) {
    return AnalyticsFilter(
      exerciseId: exerciseId ?? this.exerciseId,
      gymMachineId:
          gymMachineId != null ? gymMachineId() : this.gymMachineId,
      includeAssistedSets: includeAssistedSets ?? this.includeAssistedSets,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsFilter &&
          runtimeType == other.runtimeType &&
          exerciseId == other.exerciseId &&
          gymMachineId == other.gymMachineId &&
          includeAssistedSets == other.includeAssistedSets &&
          dateRange == other.dateRange;

  @override
  int get hashCode => Object.hash(
        exerciseId,
        gymMachineId,
        includeAssistedSets,
        dateRange,
      );
}

/// Detailed metadata for an all-time Personal Record (PR).
class PRRecordDetail {
  const PRRecordDetail({
    required this.value,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.distanceMeters,
    this.rpe,
    this.actualRestSeconds,
    required this.achievedAt,
    this.gymName,
    this.machineBrand,
    this.weightUnit = WeightUnit.KG,
    this.assistanceType = AssistanceType.solo,
    this.isHighRepEstimate = false,
  });

  final double value;
  final double? weight;
  final int? reps;
  final int? durationSeconds;
  final double? distanceMeters;
  final double? rpe;
  final int? actualRestSeconds;
  final DateTime achievedAt;
  final String? gymName;
  final String? machineBrand;
  final WeightUnit weightUnit;
  final AssistanceType assistanceType;
  final bool isHighRepEstimate;
}

/// All-time Personal Record summary for an exercise (filtered by machine & solo/assisted mode).
class ExercisePRSummary {
  const ExercisePRSummary({
    required this.exercise,
    this.bestEstimated1RM,
    this.heaviestWeight,
    this.bestSingleSetVolume,
    this.bestSessionVolume,
    this.hasMixedWeightUnits = false,
    this.distinctWeightUnits = const [],
    this.restOverloadInsight,
  });

  final Exercise exercise;
  final PRRecordDetail? bestEstimated1RM;
  final PRRecordDetail? heaviestWeight;
  final PRRecordDetail? bestSingleSetVolume;
  final PRRecordDetail? bestSessionVolume;

  /// True when viewing global mode (`gymMachineId == null`) and historical sets
  /// span multiple weight units (e.g., `KG` and `STACK_NUMBER`).
  final bool hasMixedWeightUnits;
  final List<WeightUnit> distinctWeightUnits;
  final RestOverloadComparison? restOverloadInsight;
}

/// Single chronological data point representing one workout session for an exercise.
class SessionExerciseProgressionPoint {
  const SessionExerciseProgressionPoint({
    required this.sessionId,
    required this.sessionDate,
    this.gymName,
    this.machineBrand,
    required this.weightUnit,
    this.bestEstimated1RM,
    this.isHighRep1RMEstimate = false,
    this.bestSetWeight,
    this.bestSetReps,
    this.bestSetDurationSeconds,
    this.bestSetDistanceMeters,
    required this.bestSetVolume,
    required this.totalWorkingVolume,
    this.avgActualRestSeconds,
    this.bestSetActualRestSeconds,
    this.bestSetRpe,
    required this.bestSetAssistanceType,
    required this.wasAssisted,
  });

  final String sessionId;
  final DateTime sessionDate;
  final String? gymName;
  final String? machineBrand;
  final WeightUnit weightUnit;
  final double? bestEstimated1RM;
  final bool isHighRep1RMEstimate;
  final double? bestSetWeight;
  final int? bestSetReps;
  final int? bestSetDurationSeconds;
  final double? bestSetDistanceMeters;
  final double bestSetVolume;
  final double totalWorkingVolume;
  final double? avgActualRestSeconds;
  final int? bestSetActualRestSeconds;
  final double? bestSetRpe;
  final AssistanceType bestSetAssistanceType;

  /// True if the best set on this session was performed with `AssistanceType.assisted`.
  final bool wasAssisted;
}

/// Detailed exercise and set breakdown for a completed workout session in History.
class CompletedSessionExerciseDetail {
  const CompletedSessionExerciseDetail({
    required this.sessionExercise,
    required this.exercise,
    this.machine,
    required this.sets,
  });

  final WorkoutSessionExercise sessionExercise;
  final Exercise exercise;
  final GymMachine? machine;
  final List<WorkoutSet> sets;
}

/// Summary of a completed workout session for the History Log tab.
class CompletedWorkoutSessionSummary {
  const CompletedWorkoutSessionSummary({
    required this.session,
    this.planName,
    this.gymName,
    required this.durationSeconds,
    required this.totalWorkingSets,
    required this.totalWorkingVolume,
    required this.newPRsCount,
    required this.exercises,
  });

  final WorkoutSession session;
  final String? planName;
  final String? gymName;
  final int durationSeconds;
  final int totalWorkingSets;
  final double totalWorkingVolume;
  final int newPRsCount;
  final List<CompletedSessionExerciseDetail> exercises;
}

/// Internal joined record for a session exercise and its sets.
class _SessionExerciseRecord {
  const _SessionExerciseRecord({
    required this.session,
    required this.sessionExercise,
    required this.exercise,
    this.gym,
    this.machine,
    required this.sets,
  });

  final WorkoutSession session;
  final WorkoutSessionExercise sessionExercise;
  final Exercise exercise;
  final GymLocation? gym;
  final GymMachine? machine;
  final List<WorkoutSet> sets;
}

/// Offline-first repository for PR calculations, progression series, and workout history.
class AnalyticsRepository {
  AnalyticsRepository(this._db);

  final AppDatabase _db;

  /// Returns the `gymMachineId` most recently used for [exerciseId], if any.
  Future<String?> getMostRecentMachineIdForExercise(String exerciseId) async {
    final query = _db.select(_db.workoutSessionExercises).join([
      innerJoin(
        _db.workoutSessions,
        _db.workoutSessions.id.equalsExp(
              _db.workoutSessionExercises.workoutSessionId,
            ) &
            _db.workoutSessions.deletedAt.isNull(),
      ),
      innerJoin(
        _db.gymMachines,
        _db.gymMachines.id.equalsExp(_db.workoutSessionExercises.gymMachineId) &
            _db.gymMachines.deletedAt.isNull(),
      ),
    ])
      ..where(
        _db.workoutSessionExercises.exerciseId.equals(exerciseId) &
            _db.workoutSessionExercises.deletedAt.isNull() &
            _db.workoutSessionExercises.gymMachineId.isNotNull(),
      )
      ..orderBy([
        OrderingTerm.desc(_db.workoutSessions.completedAt),
        OrderingTerm.desc(_db.workoutSessions.startedAt),
      ])
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row?.readTable(_db.workoutSessionExercises).gymMachineId;
  }

  List<TableInfo<Table, dynamic>> get _analyticsWatchedTables => [
        _db.workoutSessions,
        _db.workoutSessionExercises,
        _db.workoutSets,
        _db.gymMachines,
        _db.gymLocations,
        _db.exercises,
        _db.workoutPlans,
      ];

  /// Watches the all-time Personal Record summary for [filter].
  Stream<ExercisePRSummary?> watchExercisePRSummary(AnalyticsFilter filter) {
    return watchWithTableUpdates<ExercisePRSummary?>(
      db: _db,
      tables: _analyticsWatchedTables,
      load: () => _computeExercisePRSummary(filter),
    );
  }

  /// Watches the chronological progression series for [filter].
  Stream<List<SessionExerciseProgressionPoint>> watchExerciseProgressionSeries(
    AnalyticsFilter filter,
  ) {
    return watchWithTableUpdates<List<SessionExerciseProgressionPoint>>(
      db: _db,
      tables: _analyticsWatchedTables,
      load: () => _computeProgressionSeries(filter),
    );
  }

  /// Watches all completed workout sessions (`completedAt IS NOT NULL AND deletedAt IS NULL`),
  /// ordered from newest to oldest, including volume & PR counts.
  Stream<List<CompletedWorkoutSessionSummary>> watchCompletedWorkoutSessions() {
    return watchWithTableUpdates<List<CompletedWorkoutSessionSummary>>(
      db: _db,
      tables: _analyticsWatchedTables,
      load: _loadCompletedWorkoutSessions,
    );
  }

  Future<List<_SessionExerciseRecord>> _loadSessionRecordsForExercise(
    AnalyticsFilter filter, {
    required bool applyDateRange,
  }) async {
    final cutoff = applyDateRange ? filter.dateRange.cutoffDateUtc() : null;

    final joinQuery = _db.select(_db.workoutSessionExercises).join([
      innerJoin(
        _db.workoutSessions,
        _db.workoutSessions.id.equalsExp(
              _db.workoutSessionExercises.workoutSessionId,
            ) &
            _db.workoutSessions.deletedAt.isNull(),
      ),
      innerJoin(
        _db.exercises,
        _db.exercises.id.equalsExp(_db.workoutSessionExercises.exerciseId) &
            _db.exercises.deletedAt.isNull(),
      ),
      leftOuterJoin(
        _db.gymLocations,
        _db.gymLocations.id.equalsExp(_db.workoutSessions.gymLocationId) &
            _db.gymLocations.deletedAt.isNull(),
      ),
      leftOuterJoin(
        _db.gymMachines,
        _db.gymMachines.id.equalsExp(_db.workoutSessionExercises.gymMachineId) &
            _db.gymMachines.deletedAt.isNull(),
      ),
    ]);

    Expression<bool> predicate =
        _db.workoutSessionExercises.exerciseId.equals(filter.exerciseId) &
            _db.workoutSessionExercises.deletedAt.isNull();

    if (filter.gymMachineId != null && filter.gymMachineId!.isNotEmpty) {
      predicate = predicate &
          _db.workoutSessionExercises.gymMachineId.equals(filter.gymMachineId!);
    }

    if (cutoff != null) {
      predicate = predicate &
          _db.workoutSessions.startedAt.isBiggerOrEqualValue(cutoff);
    }

    joinQuery
      ..where(predicate)
      ..orderBy([
        OrderingTerm.asc(_db.workoutSessions.startedAt),
        OrderingTerm.asc(_db.workoutSessionExercises.sortOrder),
      ]);

    final rows = await joinQuery.get();
    if (rows.isEmpty) return const [];

    final seIds = rows
        .map((r) => r.readTable(_db.workoutSessionExercises).id)
        .toList(growable: false);

    final allSets = await (_db.select(_db.workoutSets)
          ..where(
            (tbl) =>
                tbl.workoutSessionExerciseId.isIn(seIds) &
                tbl.deletedAt.isNull(),
          )
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.setNumber),
            (tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .get();

    final setsBySeId = <String, List<WorkoutSet>>{};
    for (final s in allSets) {
      setsBySeId.putIfAbsent(s.workoutSessionExerciseId, () => []).add(s);
    }

    return rows.map((row) {
      final se = row.readTable(_db.workoutSessionExercises);
      return _SessionExerciseRecord(
        session: row.readTable(_db.workoutSessions),
        sessionExercise: se,
        exercise: row.readTable(_db.exercises),
        gym: row.readTableOrNull(_db.gymLocations),
        machine: row.readTableOrNull(_db.gymMachines),
        sets: setsBySeId[se.id] ?? const [],
      );
    }).toList(growable: false);
  }

  Future<ExercisePRSummary?> _computeExercisePRSummary(
    AnalyticsFilter filter,
  ) async {
    final exercise = await (_db.select(_db.exercises)
          ..where(
            (tbl) =>
                tbl.id.equals(filter.exerciseId) & tbl.deletedAt.isNull(),
          ))
        .getSingleOrNull();
    if (exercise == null) return null;

    // All-time records ignore dateRange cutoff so PR cards always show true all-time bests
    final records = await _loadSessionRecordsForExercise(
      filter,
      applyDateRange: false,
    );

    PRRecordDetail? best1RM;
    PRRecordDetail? heaviestWeight;
    PRRecordDetail? bestSingleSetVolume;
    PRRecordDetail? bestSessionVolume;

    final usedUnits = <WeightUnit>{};
    final sessionSnapshots = <SessionPerformanceSnapshot>[];

    for (final record in records) {
      final eligibleSets = WorkoutCalculator.filterWorkingSets(
        record.sets,
        includeAssistedSets: filter.includeAssistedSets,
      );
      if (eligibleSets.isEmpty) continue;

      final unit = record.machine?.weightUnit ?? WeightUnit.KG;
      usedUnits.add(unit);
      final achievedDate =
          record.session.completedAt ?? record.session.startedAt;

      var sessionTotalVol = 0.0;
      var sessionBestVol = 0.0;
      var sessionBestWeight = 0.0;
      var sessionBestReps = 0;

      for (final s in eligibleSets) {
        // 1. Estimated 1RM (Epley)
        final e1rmRes = WorkoutCalculator.calculateSetEstimated1RM(
          s,
          exerciseType: exercise.exerciseType,
          includeAssistedSets: filter.includeAssistedSets,
        );
        if (e1rmRes != null) {
          if (best1RM == null || e1rmRes.e1rm > best1RM.value) {
            best1RM = PRRecordDetail(
              value: e1rmRes.e1rm,
              weight: s.weight,
              reps: s.reps,
              rpe: s.rpe,
              actualRestSeconds: s.actualRestSeconds,
              achievedAt: achievedDate,
              gymName: record.gym?.name,
              machineBrand: record.machine?.brandName,
              weightUnit: unit,
              assistanceType: s.assistanceType,
              isHighRepEstimate: e1rmRes.isHighRepEstimate,
            );
          }
        }

        // 2. Heaviest Weight (at least 1 rep or positive duration/distance)
        final w = s.weight;
        final r = s.reps ?? 1;
        if (w != null && w > 0 && r >= 1) {
          final isAssistedBw =
              exercise.exerciseType == ExerciseType.assisted_bodyweight;
          final isNewBestWeight = bestHeaviestCheck(
            candidateWeight: w,
            candidateReps: r,
            currentBest: heaviestWeight,
            isAssistedBodyweight: isAssistedBw,
          );
          if (isNewBestWeight) {
            heaviestWeight = PRRecordDetail(
              value: w,
              weight: w,
              reps: s.reps,
              durationSeconds: s.durationSeconds,
              distanceMeters: s.distanceMeters,
              rpe: s.rpe,
              actualRestSeconds: s.actualRestSeconds,
              achievedAt: achievedDate,
              gymName: record.gym?.name,
              machineBrand: record.machine?.brandName,
              weightUnit: unit,
              assistanceType: s.assistanceType,
            );
          }

          if (w > sessionBestWeight ||
              (w == sessionBestWeight && r > sessionBestReps)) {
            sessionBestWeight = w;
            sessionBestReps = r;
          }
        }

        // 3. Best Single Set Volume
        final setVol = WorkoutCalculator.calculateSetVolume(
          s,
          exerciseType: exercise.exerciseType,
          includeAssistedSets: filter.includeAssistedSets,
        );
        if (setVol > 0) {
          sessionTotalVol += setVol;
          if (setVol > sessionBestVol) {
            sessionBestVol = setVol;
          }
          if (bestSingleSetVolume == null ||
              setVol > bestSingleSetVolume.value) {
            bestSingleSetVolume = PRRecordDetail(
              value: setVol,
              weight: s.weight,
              reps: s.reps,
              durationSeconds: s.durationSeconds,
              distanceMeters: s.distanceMeters,
              rpe: s.rpe,
              actualRestSeconds: s.actualRestSeconds,
              achievedAt: achievedDate,
              gymName: record.gym?.name,
              machineBrand: record.machine?.brandName,
              weightUnit: unit,
              assistanceType: s.assistanceType,
            );
          }
        }
      }

      // 4. Best Session Volume
      if (sessionTotalVol > 0) {
        if (bestSessionVolume == null ||
            sessionTotalVol > bestSessionVolume.value) {
          bestSessionVolume = PRRecordDetail(
            value: sessionTotalVol,
            achievedAt: achievedDate,
            gymName: record.gym?.name,
            machineBrand: record.machine?.brandName,
            weightUnit: unit,
          );
        }
      }

      final avgRest = WorkoutCalculator.calculateAverageActualRestSeconds(
        eligibleSets,
        includeAssistedSets: filter.includeAssistedSets,
      );
      sessionSnapshots.add(
        SessionPerformanceSnapshot(
          bestWeight: sessionBestWeight,
          bestReps: sessionBestReps,
          bestSetVolume: sessionBestVol,
          avgActualRestSeconds: avgRest,
        ),
      );
    }

    RestOverloadComparison? restInsight;
    if (sessionSnapshots.length >= 2) {
      restInsight = WorkoutCalculator.evaluateRestProgressiveOverload(
        previous: sessionSnapshots[sessionSnapshots.length - 2],
        current: sessionSnapshots.last,
      );
    }

    return ExercisePRSummary(
      exercise: exercise,
      bestEstimated1RM: best1RM,
      heaviestWeight: heaviestWeight,
      bestSingleSetVolume: bestSingleSetVolume,
      bestSessionVolume: bestSessionVolume,
      hasMixedWeightUnits:
          filter.gymMachineId == null && usedUnits.length > 1,
      distinctWeightUnits: usedUnits.toList(growable: false),
      restOverloadInsight: restInsight,
    );
  }

  bool bestHeaviestCheck({
    required double candidateWeight,
    required int candidateReps,
    required PRRecordDetail? currentBest,
    required bool isAssistedBodyweight,
  }) {
    if (currentBest == null) return true;
    final bestW = currentBest.value;
    final bestR = currentBest.reps ?? 0;
    if (isAssistedBodyweight) {
      // Lower counter-weight = stronger
      if (candidateWeight < bestW) return true;
      if (candidateWeight == bestW && candidateReps > bestR) return true;
      return false;
    }
    if (candidateWeight > bestW) return true;
    if (candidateWeight == bestW && candidateReps > bestR) return true;
    return false;
  }

  Future<List<SessionExerciseProgressionPoint>> _computeProgressionSeries(
    AnalyticsFilter filter,
  ) async {
    final records = await _loadSessionRecordsForExercise(
      filter,
      applyDateRange: true,
    );
    if (records.isEmpty) return const [];

    final points = <SessionExerciseProgressionPoint>[];

    for (final record in records) {
      final eligibleSets = WorkoutCalculator.filterWorkingSets(
        record.sets,
        includeAssistedSets: filter.includeAssistedSets,
      );
      if (eligibleSets.isEmpty) continue;

      final exerciseType = record.exercise.exerciseType;
      final unit = record.machine?.weightUnit ?? WeightUnit.KG;

      double? best1RM;
      var isHighRep1RM = false;
      WorkoutSet? primaryBestSet;
      var bestSetVol = 0.0;
      var totalWorkingVol = 0.0;

      for (final s in eligibleSets) {
        final e1rmRes = WorkoutCalculator.calculateSetEstimated1RM(
          s,
          exerciseType: exerciseType,
          includeAssistedSets: filter.includeAssistedSets,
        );
        if (e1rmRes != null && (best1RM == null || e1rmRes.e1rm > best1RM)) {
          best1RM = e1rmRes.e1rm;
          isHighRep1RM = e1rmRes.isHighRepEstimate;
          primaryBestSet = s;
        }

        final vol = WorkoutCalculator.calculateSetVolume(
          s,
          exerciseType: exerciseType,
          includeAssistedSets: filter.includeAssistedSets,
        );
        totalWorkingVol += vol;
        if (vol >= bestSetVol) {
          bestSetVol = vol;
          primaryBestSet ??= s;
        }
      }

      final chosenSet = primaryBestSet ?? eligibleSets.first;
      final avgRest = WorkoutCalculator.calculateAverageActualRestSeconds(
        eligibleSets,
        includeAssistedSets: filter.includeAssistedSets,
      );
      final anyAssisted =
          chosenSet.assistanceType == AssistanceType.assisted ||
              eligibleSets.any(
                (s) => s.assistanceType == AssistanceType.assisted,
              );

      points.add(
        SessionExerciseProgressionPoint(
          sessionId: record.session.id,
          sessionDate:
              record.session.completedAt ?? record.session.startedAt,
          gymName: record.gym?.name,
          machineBrand: record.machine?.brandName,
          weightUnit: unit,
          bestEstimated1RM: best1RM,
          isHighRep1RMEstimate: isHighRep1RM,
          bestSetWeight: chosenSet.weight,
          bestSetReps: chosenSet.reps,
          bestSetDurationSeconds: chosenSet.durationSeconds,
          bestSetDistanceMeters: chosenSet.distanceMeters,
          bestSetVolume: bestSetVol,
          totalWorkingVolume: totalWorkingVol,
          avgActualRestSeconds: avgRest,
          bestSetActualRestSeconds: chosenSet.actualRestSeconds,
          bestSetRpe: chosenSet.rpe,
          bestSetAssistanceType: chosenSet.assistanceType,
          wasAssisted: anyAssisted,
        ),
      );
    }

    return points;
  }

  Future<List<CompletedWorkoutSessionSummary>>
      _loadCompletedWorkoutSessions() async {
    final sessions = await (_db.select(_db.workoutSessions)
          ..where(
            (tbl) => tbl.completedAt.isNotNull() & tbl.deletedAt.isNull(),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.completedAt)]))
        .get();

    if (sessions.isEmpty) return const [];

    final plans = await (_db.select(_db.workoutPlans)
          ..where((tbl) => tbl.deletedAt.isNull()))
        .get();
    final planMap = {for (final p in plans) p.id: p};

    final gyms = await (_db.select(_db.gymLocations)
          ..where((tbl) => tbl.deletedAt.isNull()))
        .get();
    final gymMap = {for (final g in gyms) g.id: g};

    final exercises = await (_db.select(_db.exercises)
          ..where((tbl) => tbl.deletedAt.isNull()))
        .get();
    final exerciseMap = {for (final e in exercises) e.id: e};

    final machines = await (_db.select(_db.gymMachines)
          ..where((tbl) => tbl.deletedAt.isNull()))
        .get();
    final machineMap = {for (final m in machines) m.id: m};

    final sessionIds = sessions.map((s) => s.id).toList(growable: false);
    final allSessionExercises = await (_db.select(_db.workoutSessionExercises)
          ..where(
            (tbl) =>
                tbl.workoutSessionId.isIn(sessionIds) & tbl.deletedAt.isNull(),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();

    final seIds = allSessionExercises.map((e) => e.id).toList(growable: false);
    final allSets = seIds.isEmpty
        ? const <WorkoutSet>[]
        : await (_db.select(_db.workoutSets)
              ..where(
                (tbl) =>
                    tbl.workoutSessionExerciseId.isIn(seIds) &
                    tbl.deletedAt.isNull(),
              )
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.setNumber),
                (tbl) => OrderingTerm.asc(tbl.createdAt),
              ]))
            .get();

    final seBySessionId = <String, List<WorkoutSessionExercise>>{};
    for (final se in allSessionExercises) {
      seBySessionId.putIfAbsent(se.workoutSessionId, () => []).add(se);
    }

    final setsBySeId = <String, List<WorkoutSet>>{};
    for (final s in allSets) {
      setsBySeId.putIfAbsent(s.workoutSessionExerciseId, () => []).add(s);
    }

    // Track running Solo 1RM / Volume PR per (exerciseId, gymMachineId) in chronological order
    final runningBest1RM = <String, double>{};
    final runningBestSetVol = <String, double>{};
    final chronologicalSummaries = <CompletedWorkoutSessionSummary>[];

    for (final session in sessions) {
      final seList = seBySessionId[session.id] ?? const [];
      final exerciseDetails = <CompletedSessionExerciseDetail>[];
      var sessionWorkingSets = 0;
      var sessionVolume = 0.0;
      var sessionPRs = 0;

      for (final se in seList) {
        final ex = exerciseMap[se.exerciseId];
        if (ex == null) continue;
        final machine =
            se.gymMachineId != null ? machineMap[se.gymMachineId!] : null;
        final setsForEx = setsBySeId[se.id] ?? const [];

        exerciseDetails.add(
          CompletedSessionExerciseDetail(
            sessionExercise: se,
            exercise: ex,
            machine: machine,
            sets: setsForEx,
          ),
        );

        final prKey = '${ex.id}::${se.gymMachineId ?? "global"}';
        final priorBest1RM = runningBest1RM[prKey];
        final priorBestVol = runningBestSetVol[prKey];
        var brokePrOnThisExercise = false;

        for (final s in setsForEx) {
          if (!WorkoutCalculator.isEligibleWorkingSet(
            s,
            includeAssistedSets: false,
          )) {
            continue;
          }
          sessionWorkingSets++;
          final vol = WorkoutCalculator.calculateSetVolume(
            s,
            exerciseType: ex.exerciseType,
            includeAssistedSets: false,
          );
          sessionVolume += vol;

          final e1rm = WorkoutCalculator.calculateSetEstimated1RM(
            s,
            exerciseType: ex.exerciseType,
            includeAssistedSets: false,
          )?.e1rm;

          if (e1rm != null) {
            if (priorBest1RM != null && e1rm > priorBest1RM) {
              brokePrOnThisExercise = true;
            }
            final curr = runningBest1RM[prKey] ?? 0.0;
            if (e1rm > curr) runningBest1RM[prKey] = e1rm;
          }

          if (vol > 0) {
            if (priorBestVol != null && vol > priorBestVol) {
              brokePrOnThisExercise = true;
            }
            final currV = runningBestSetVol[prKey] ?? 0.0;
            if (vol > currV) runningBestSetVol[prKey] = vol;
          }
        }

        if (brokePrOnThisExercise) {
          sessionPRs++;
        }
      }

      final durationSec = session.completedAt!
          .toUtc()
          .difference(session.startedAt.toUtc())
          .inSeconds
          .clamp(0, 86400);

      chronologicalSummaries.add(
        CompletedWorkoutSessionSummary(
          session: session,
          planName: session.workoutPlanId != null
              ? planMap[session.workoutPlanId!]?.name
              : null,
          gymName: session.gymLocationId != null
              ? gymMap[session.gymLocationId!]?.name
              : null,
          durationSeconds: durationSec,
          totalWorkingSets: sessionWorkingSets,
          totalWorkingVolume: sessionVolume,
          newPRsCount: sessionPRs,
          exercises: exerciseDetails,
        ),
      );
    }

    // Return newest first
    return chronologicalSummaries.reversed.toList(growable: false);
  }

  /// Updates the notes of a completed workout session (`syncStatus = SyncStatus.pendingPush`).
  Future<void> updateSessionNotes({
    required String sessionId,
    String? sessionNotes,
  }) async {
    final now = DateTime.now().toUtc();
    final trimmed = sessionNotes?.trim();
    await (_db.update(_db.workoutSessions)
          ..where((tbl) => tbl.id.equals(sessionId) & tbl.deletedAt.isNull()))
        .write(
      WorkoutSessionsCompanion(
        sessionNotes: Value(
          trimmed == null || trimmed.isEmpty ? null : trimmed,
        ),
        updatedAt: Value(now),
        syncStatus: Value(SyncStatus.pendingPush),
      ),
    );
  }

  /// Soft-deletes a completed workout session and its child exercises/sets.
  Future<void> softDeleteCompletedSession(String sessionId) async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.workoutSessions)
            ..where((tbl) => tbl.id.equals(sessionId) & tbl.deletedAt.isNull()))
          .write(
        WorkoutSessionsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: Value(SyncStatus.pendingDelete),
        ),
      );

      final seRows = await (_db.select(_db.workoutSessionExercises)
            ..where((tbl) => tbl.workoutSessionId.equals(sessionId)))
          .get();
      final seIds = seRows.map((e) => e.id).toList(growable: false);

      await (_db.update(_db.workoutSessionExercises)
            ..where((tbl) => tbl.workoutSessionId.equals(sessionId)))
          .write(
        WorkoutSessionExercisesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: Value(SyncStatus.pendingDelete),
        ),
      );

      if (seIds.isNotEmpty) {
        await (_db.update(_db.workoutSets)
              ..where((tbl) => tbl.workoutSessionExerciseId.isIn(seIds)))
            .write(
          WorkoutSetsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            syncStatus: Value(SyncStatus.pendingDelete),
          ),
        );
      }
    });
  }
}

@Riverpod(keepAlive: true)
AnalyticsRepository analyticsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return AnalyticsRepository(db);
}
