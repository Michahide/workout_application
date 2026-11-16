import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';

/// Result of an Estimated 1RM calculation using the Epley formula.
class Estimated1RMResult {
  const Estimated1RMResult({
    required this.e1rm,
    required this.weight,
    required this.reps,
    required this.isHighRepEstimate,
    required this.brzyckiFallback,
  });

  /// Epley 1RM: `weight` when `reps == 1`, else `weight * (1 + reps / 30.0)`.
  final double e1rm;
  final double weight;
  final int reps;

  /// True when `reps > 12`, indicating lower 1RM estimation confidence.
  final bool isHighRepEstimate;

  /// Brzycki formula value for reference on higher-rep sets.
  final double brzyckiFallback;
}

/// Snapshot of a session's best performance and average rest for progressive overload comparison.
class SessionPerformanceSnapshot {
  const SessionPerformanceSnapshot({
    required this.bestWeight,
    required this.bestReps,
    required this.bestSetVolume,
    required this.avgActualRestSeconds,
  });

  final double bestWeight;
  final int bestReps;
  final double bestSetVolume;
  final double? avgActualRestSeconds;
}

/// Result of comparing two sessions for Rest Time Progressive Overload
/// (workout density improvement).
class RestOverloadComparison {
  const RestOverloadComparison({
    required this.isRestProgressiveOverload,
    required this.restDeltaSeconds,
    required this.summary,
  });

  /// True when the lifter matched or beat the previous session's best set while
  /// resting strictly less (`restDeltaSeconds < 0`).
  final bool isRestProgressiveOverload;

  /// Negative value means rest time decreased (improved density).
  final double restDeltaSeconds;
  final String summary;
}

/// Pure Dart domain calculator for PRs, Epley 1RM, working volume, and rest efficiency.
class WorkoutCalculator {
  const WorkoutCalculator._();

  /// Strict eligibility check for analytics & PR calculations:
  /// - Must be completed (`isCompleted == true`)
  /// - Must not be soft-deleted (`deletedAt == null`)
  /// - Must NOT be a warm-up set (`setType != SetType.warmup`)
  /// - When `includeAssistedSets == false` (Solo Mode default), only `solo` and
  ///   `spotted_no_touch` sets are eligible (`assisted` sets are excluded).
  static bool isEligibleWorkingSet(
    WorkoutSet workoutSet, {
    bool includeAssistedSets = false,
  }) {
    if (!workoutSet.isCompleted) return false;
    if (workoutSet.deletedAt != null) return false;
    if (workoutSet.setType == SetType.warmup) return false;

    if (!includeAssistedSets &&
        workoutSet.assistanceType == AssistanceType.assisted) {
      return false;
    }

    return true;
  }

  /// Filters a list of [WorkoutSet]s down to eligible working sets.
  static List<WorkoutSet> filterWorkingSets(
    Iterable<WorkoutSet> sets, {
    bool includeAssistedSets = false,
  }) {
    return sets
        .where(
          (s) => isEligibleWorkingSet(
            s,
            includeAssistedSets: includeAssistedSets,
          ),
        )
        .toList(growable: false);
  }

  /// Calculates Estimated 1RM using the Epley formula:
  /// - If `reps == 1`: `e1RM = weight`
  /// - If `reps > 1`: `e1RM = weight * (1 + (reps / 30.0))`
  /// - Flags `isHighRepEstimate = reps > 12`.
  static Estimated1RMResult? calculateEstimated1RM({
    required double? weight,
    required int? reps,
  }) {
    if (weight == null || weight <= 0 || reps == null || reps <= 0) {
      return null;
    }

    final e1rm = reps == 1 ? weight : weight * (1.0 + (reps / 30.0));
    final brzycki = reps == 1
        ? weight
        : (reps < 37 ? weight * (36.0 / (37.0 - reps)) : e1rm);

    return Estimated1RMResult(
      e1rm: e1rm,
      weight: weight,
      reps: reps,
      isHighRepEstimate: reps > 12,
      brzyckiFallback: brzycki,
    );
  }

  /// Calculates Estimated 1RM for a [WorkoutSet] if it is an eligible working set.
  static Estimated1RMResult? calculateSetEstimated1RM(
    WorkoutSet workoutSet, {
    ExerciseType exerciseType = ExerciseType.weight_reps,
    bool includeAssistedSets = false,
    double? userBodyweight,
  }) {
    if (!isEligibleWorkingSet(
      workoutSet,
      includeAssistedSets: includeAssistedSets,
    )) {
      return null;
    }

    switch (exerciseType) {
      case ExerciseType.weight_reps:
      case ExerciseType.weighted_bodyweight:
        return calculateEstimated1RM(
          weight: workoutSet.weight,
          reps: workoutSet.reps,
        );
      case ExerciseType.assisted_bodyweight:
        final assisted = workoutSet.weight;
        if (assisted == null || workoutSet.reps == null) return null;
        if (userBodyweight != null && userBodyweight > assisted) {
          final effectiveLoad = userBodyweight - assisted;
          return calculateEstimated1RM(
            weight: effectiveLoad,
            reps: workoutSet.reps,
          );
        }
        return null;
      case ExerciseType.bodyweight_reps:
      case ExerciseType.duration:
      case ExerciseType.duration_weight:
      case ExerciseType.distance_duration:
      case ExerciseType.weight_distance:
        return null;
    }
  }

  /// Calculates single-set volume/score according to [ExerciseType].
  /// Returns `0.0` if the set is not an eligible working set.
  static double calculateSetVolume(
    WorkoutSet workoutSet, {
    required ExerciseType exerciseType,
    bool includeAssistedSets = false,
    double? userBodyweight,
  }) {
    if (!isEligibleWorkingSet(
      workoutSet,
      includeAssistedSets: includeAssistedSets,
    )) {
      return 0.0;
    }

    final weight = workoutSet.weight ?? 0.0;
    final reps = workoutSet.reps ?? 0;
    final duration = workoutSet.durationSeconds ?? 0;
    final distance = workoutSet.distanceMeters ?? 0.0;

    switch (exerciseType) {
      case ExerciseType.weight_reps:
      case ExerciseType.weighted_bodyweight:
        if (weight <= 0 || reps <= 0) return 0.0;
        return weight * reps;

      case ExerciseType.assisted_bodyweight:
        if (reps <= 0) return 0.0;
        if (userBodyweight != null && userBodyweight > weight) {
          return (userBodyweight - weight) * reps;
        }
        // Without user bodyweight, represent volume by reps completed
        return reps.toDouble();

      case ExerciseType.bodyweight_reps:
        return reps > 0 ? reps.toDouble() : 0.0;

      case ExerciseType.duration:
        return duration > 0 ? duration.toDouble() : 0.0;

      case ExerciseType.duration_weight:
        if (weight > 0 && duration > 0) return weight * duration;
        return duration > 0 ? duration.toDouble() : 0.0;

      case ExerciseType.distance_duration:
        return distance > 0 ? distance : duration.toDouble();

      case ExerciseType.weight_distance:
        if (weight > 0 && distance > 0) return weight * distance;
        return distance;
    }
  }

  /// Calculates total working volume across all eligible sets in a session.
  /// Warm-up sets (`SetType.warmup`) are strictly excluded.
  static double calculateTotalWorkingVolume(
    Iterable<WorkoutSet> sets, {
    required ExerciseType exerciseType,
    bool includeAssistedSets = false,
    double? userBodyweight,
  }) {
    var total = 0.0;
    for (final s in sets) {
      total += calculateSetVolume(
        s,
        exerciseType: exerciseType,
        includeAssistedSets: includeAssistedSets,
        userBodyweight: userBodyweight,
      );
    }
    return total;
  }

  /// For `ExerciseType.assisted_bodyweight`, determines whether [candidate]
  /// represents better strength progression than [incumbent]
  /// (less counter-weight assistance, or more reps at the same counter-weight).
  static bool isBetterAssistedBodyweightSet(
    WorkoutSet candidate,
    WorkoutSet incumbent,
  ) {
    final cWeight = candidate.weight;
    final iWeight = incumbent.weight;
    final cReps = candidate.reps ?? 0;
    final iReps = incumbent.reps ?? 0;

    if (cWeight == null) return false;
    if (iWeight == null) return true;

    if (cWeight < iWeight && cReps >= iReps) return true;
    if (cWeight == iWeight && cReps > iReps) return true;
    return cWeight < iWeight;
  }

  /// Computes the average `actualRestSeconds` across eligible working sets.
  static double? calculateAverageActualRestSeconds(
    Iterable<WorkoutSet> sets, {
    bool includeAssistedSets = false,
  }) {
    final restValues = sets
        .where(
          (s) =>
              isEligibleWorkingSet(
                s,
                includeAssistedSets: includeAssistedSets,
              ) &&
              s.actualRestSeconds != null &&
              s.actualRestSeconds! > 0,
        )
        .map((s) => s.actualRestSeconds!)
        .toList(growable: false);

    if (restValues.isEmpty) return null;
    final sum = restValues.fold<int>(0, (acc, v) => acc + v);
    return sum / restValues.length;
  }

  /// Evaluates whether [current] achieved Rest Time Progressive Overload
  /// compared to [previous] (matching or exceeding weight/reps/volume while
  /// reducing average actual rest time).
  static RestOverloadComparison evaluateRestProgressiveOverload({
    required SessionPerformanceSnapshot previous,
    required SessionPerformanceSnapshot current,
  }) {
    final prevRest = previous.avgActualRestSeconds;
    final currRest = current.avgActualRestSeconds;

    if (prevRest == null || currRest == null || prevRest <= 0 || currRest <= 0) {
      return const RestOverloadComparison(
        isRestProgressiveOverload: false,
        restDeltaSeconds: 0,
        summary: 'Data waktu istirahat belum cukup untuk dibandingkan.',
      );
    }

    final delta = currRest - prevRest;
    final matchedOrBeatLoad =
        (current.bestWeight >= previous.bestWeight &&
            current.bestReps >= previous.bestReps) ||
        current.bestSetVolume >= previous.bestSetVolume;

    final isOverload = matchedOrBeatLoad && delta < 0;
    final absDelta = delta.abs().round();

    if (isOverload) {
      return RestOverloadComparison(
        isRestProgressiveOverload: true,
        restDeltaSeconds: delta,
        summary:
            'Rest Time Progressive Overload! Istirahat rata-rata lebih singkat ${absDelta}s dengan beban/volume setara atau lebih tinggi.',
      );
    }

    return RestOverloadComparison(
      isRestProgressiveOverload: false,
      restDeltaSeconds: delta,
      summary: delta <= 0
          ? 'Istirahat lebih singkat ${absDelta}s dibanding sesi sebelumnya.'
          : 'Istirahat rata-rata +${absDelta}s lebih lama dibanding sesi sebelumnya.',
    );
  }
}
