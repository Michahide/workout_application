import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/exercise_analytics_view.dart';
import 'workout_history_tab.dart';

/// Main Analytics & Workout History screen (Tab 5 in Bottom Navigation Bar)
/// containing two sub-tabs:
/// 1. Exercise Progress & PRs (with machine filter, Solo/Assisted toggle, Bento PRs, and `fl_chart`)
/// 2. Workout History Log (chronological completed sessions with edit & soft-delete support)
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({
    super.key,
    this.initialExerciseId,
    this.initialGymMachineId,
  });

  final String? initialExerciseId;
  final String? initialGymMachineId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics & History'),
          actions: [
            IconButton(
              tooltip: 'Pengaturan Rest Timer',
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.insights_rounded, size: 18),
                text: 'Progress & PRs',
              ),
              Tab(
                icon: Icon(Icons.history_rounded, size: 18),
                text: 'Workout History',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ExerciseAnalyticsView(
              initialExerciseId: initialExerciseId,
              initialGymMachineId: initialGymMachineId,
            ),
            const WorkoutHistoryTab(),
          ],
        ),
      ),
    );
  }
}
