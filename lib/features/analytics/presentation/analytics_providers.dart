import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/analytics_repository.dart';

/// Available chart metrics for Exercise Progression.
enum AnalyticsChartMetric {
  estimated1RM('Est. 1RM', 'Estimasi 1RM Puncak (Epley)'),
  bestSetVolume('Best Set Vol', 'Volume Set Terbaik (Weight × Reps)'),
  totalSessionVolume('Total Vol', 'Total Volume Working Set Sesi'),
  actualRestSeconds('Rest Trend', 'Rata-rata Actual Rest Antar Set (Detik)');

  const AnalyticsChartMetric(this.shortLabel, this.fullTitle);

  final String shortLabel;
  final String fullTitle;
}

final exercisePRSummaryProvider = StreamProvider.autoDispose
    .family<ExercisePRSummary?, AnalyticsFilter>((ref, filter) {
      final repo = ref.watch(analyticsRepositoryProvider);
      return repo.watchExercisePRSummary(filter);
    });

final exerciseProgressionSeriesProvider = StreamProvider.autoDispose
    .family<List<SessionExerciseProgressionPoint>, AnalyticsFilter>((
      ref,
      filter,
    ) {
      final repo = ref.watch(analyticsRepositoryProvider);
      return repo.watchExerciseProgressionSeries(filter);
    });

final completedWorkoutSessionsProvider =
    StreamProvider.autoDispose<List<CompletedWorkoutSessionSummary>>((ref) {
      final repo = ref.watch(analyticsRepositoryProvider);
      return repo.watchCompletedWorkoutSessions();
    });

final mostRecentMachineForExerciseProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, exerciseId) {
      final repo = ref.watch(analyticsRepositoryProvider);
      return repo.getMostRecentMachineIdForExercise(exerciseId);
    });
