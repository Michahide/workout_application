import 'package:flutter_test/flutter_test.dart';
import 'package:workout_application/core/database/app_database.dart';
import 'package:workout_application/core/database/syncable_table_mixin.dart';
import 'package:workout_application/core/database/tables.dart';
import 'package:workout_application/features/analytics/domain/workout_calculator.dart';

WorkoutSet _makeSet({
  required String id,
  int setNumber = 1,
  SetType setType = SetType.normal,
  double? weight = 100.0,
  int? reps = 10,
  AssistanceType assistanceType = AssistanceType.solo,
  int? actualRestSeconds = 150,
  bool isCompleted = true,
  DateTime? deletedAt,
}) {
  final now = DateTime.utc(2026, 11, 16);
  return WorkoutSet(
    id: id,
    createdAt: now,
    updatedAt: now,
    deletedAt: deletedAt,
    syncStatus: SyncStatus.synced,
    workoutSessionExerciseId: 'se-1',
    setNumber: setNumber,
    parentSetId: null,
    setType: setType,
    weight: weight,
    reps: reps,
    durationSeconds: null,
    distanceMeters: null,
    rpe: 8.5,
    assistanceType: assistanceType,
    targetRestSeconds: 180,
    actualRestSeconds: actualRestSeconds,
    isCompleted: isCompleted,
    completedAt: isCompleted ? now : null,
  );
}

void main() {
  group('WorkoutCalculator - Epley 1RM & High-Rep Flag', () {
    test('returns exact weight when reps == 1', () {
      final result = WorkoutCalculator.calculateEstimated1RM(
        weight: 120.0,
        reps: 1,
      );
      expect(result, isNotNull);
      expect(result!.e1rm, closeTo(120.0, 0.001));
      expect(result.isHighRepEstimate, isFalse);
    });

    test('calculates Epley formula accurately for multi-rep sets', () {
      // 100 * (1 + 10/30) = 133.333...
      final result = WorkoutCalculator.calculateEstimated1RM(
        weight: 100.0,
        reps: 10,
      );
      expect(result, isNotNull);
      expect(result!.e1rm, closeTo(133.3333, 0.001));
      expect(result.isHighRepEstimate, isFalse);
    });

    test('flags isHighRepEstimate when reps > 12', () {
      final result = WorkoutCalculator.calculateEstimated1RM(
        weight: 80.0,
        reps: 15,
      );
      expect(result, isNotNull);
      // 80 * (1 + 15/30) = 120.0
      expect(result!.e1rm, closeTo(120.0, 0.001));
      expect(result.isHighRepEstimate, isTrue);
    });
  });

  group('WorkoutCalculator - Warm-up Set Exclusion', () {
    test('strictly excludes warmup sets from volume and 1RM calculations', () {
      final warmupSet = _makeSet(
        id: 'warmup-1',
        setType: SetType.warmup,
        weight: 140.0,
        reps: 5,
      );
      final workingSet = _makeSet(
        id: 'working-1',
        setType: SetType.normal,
        weight: 100.0,
        reps: 8,
      );

      expect(
        WorkoutCalculator.calculateSetEstimated1RM(warmupSet),
        isNull,
      );
      expect(
        WorkoutCalculator.calculateSetVolume(
          warmupSet,
          exerciseType: ExerciseType.weight_reps,
        ),
        equals(0.0),
      );

      final totalVol = WorkoutCalculator.calculateTotalWorkingVolume(
        [warmupSet, workingSet],
        exerciseType: ExerciseType.weight_reps,
      );
      // Only workingSet (100 * 8 = 800) is counted; warmupSet (140 * 5 = 700) is ignored
      expect(totalVol, equals(800.0));
    });
  });

  group('WorkoutCalculator - Solo vs Assisted Filtering', () {
    test(
      'excludes assisted sets when includeAssistedSets == false, and includes spotted_no_touch',
      () {
        final soloSet = _makeSet(
          id: 'solo-1',
          weight: 90.0,
          reps: 8,
          assistanceType: AssistanceType.solo,
        );
        final spottedNoTouchSet = _makeSet(
          id: 'spotted-1',
          weight: 95.0,
          reps: 8,
          assistanceType: AssistanceType.spotted_no_touch,
        );
        final assistedSet = _makeSet(
          id: 'assisted-1',
          weight: 110.0,
          reps: 8,
          assistanceType: AssistanceType.assisted,
        );

        final soloFiltered = WorkoutCalculator.filterWorkingSets(
          [soloSet, spottedNoTouchSet, assistedSet],
          includeAssistedSets: false,
        );
        expect(soloFiltered.map((s) => s.id), equals(['solo-1', 'spotted-1']));

        expect(
          WorkoutCalculator.calculateSetEstimated1RM(
            assistedSet,
            includeAssistedSets: false,
          ),
          isNull,
        );
        expect(
          WorkoutCalculator.calculateSetEstimated1RM(
            assistedSet,
            includeAssistedSets: true,
          ),
          isNotNull,
        );
      },
    );
  });
}
