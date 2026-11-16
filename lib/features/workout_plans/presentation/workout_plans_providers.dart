import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/workout_plan_repository.dart';

final workoutPlansWithExercisesProvider =
    StreamProvider.autoDispose<List<WorkoutPlanWithExercises>>((ref) {
      final repo = ref.watch(workoutPlanRepositoryProvider);
      return repo.watchPlansWithExercises();
    });
