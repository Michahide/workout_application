import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/active_workout/data/active_workout_repository.dart';
import '../../features/active_workout/domain/rest_timer_controller.dart';
import '../../features/active_workout/presentation/active_workout_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/exercise_library/presentation/exercise_detail_screen.dart';
import '../../features/exercise_library/presentation/exercise_library_screen.dart';
import '../../features/gym_locations/presentation/gym_location_detail_screen.dart';
import '../../features/gym_locations/presentation/gym_locations_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/workout_plans/presentation/workout_plans_screen.dart';
import '../database/domain_labels.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/gyms',
    routes: [
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // 0: Gyms
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gyms',
                builder: (context, state) => const GymLocationsScreen(),
                routes: [
                  GoRoute(
                    path: ':gymId',
                    builder: (context, state) => GymLocationDetailScreen(
                      gymId: state.pathParameters['gymId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 1: Exercises
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exercises',
                builder: (context, state) => const ExerciseLibraryScreen(),
                routes: [
                  GoRoute(
                    path: ':exerciseId',
                    builder: (context, state) => ExerciseDetailScreen(
                      exerciseId: state.pathParameters['exerciseId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 2: Plans
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plans',
                builder: (context, state) => const WorkoutPlansScreen(),
              ),
            ],
          ),
          // 3: Active Workout
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workout',
                builder: (context, state) => const ActiveWorkoutScreen(),
              ),
            ],
          ),
          // 4: Analytics & History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => AnalyticsScreen(
                  initialExerciseId:
                      state.uri.queryParameters['exerciseId'],
                  initialGymMachineId:
                      state.uri.queryParameters['gymMachineId'],
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class AppShellScaffold extends ConsumerWidget {
  const AppShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionAsync = ref.watch(activeWorkoutSessionStreamProvider);
    final activeDetails = activeSessionAsync.asData?.value;
    final isOnWorkoutTab = navigationShell.currentIndex == 3;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (activeDetails != null && !isOnWorkoutTab)
            _ActiveWorkoutMiniPlayerBanner(
              details: activeDetails,
              onTapResume: () => _onDestinationSelected(3),
            ),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: 'Gyms',
              ),
              const NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center_rounded),
                label: 'Exercises',
              ),
              const NavigationDestination(
                icon: Icon(Icons.event_note_outlined),
                selectedIcon: Icon(Icons.event_note_rounded),
                label: 'Plans',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: activeDetails != null,
                  child: const Icon(Icons.timer_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: activeDetails != null,
                  child: const Icon(Icons.timer_rounded),
                ),
                label: 'Workout',
              ),
              const NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights_rounded),
                label: 'Analytics',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Persistent mini-player banner shown above the BottomNavigationBar whenever
/// an active workout session is running and the user is browsing another tab.
class _ActiveWorkoutMiniPlayerBanner extends ConsumerWidget {
  const _ActiveWorkoutMiniPlayerBanner({
    required this.details,
    required this.onTapResume,
  });

  final ActiveWorkoutSessionDetails details;
  final VoidCallback onTapResume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final title = details.workoutPlan?.name ?? 'Empty Workout';
    final gymName = details.gymLocation?.name ?? 'Gym';

    return Material(
      color: colorScheme.primaryContainer,
      elevation: 4,
      child: InkWell(
        onTap: onTapResume,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$title • $gymName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      timerState.isRunning
                          ? 'Rest Timer: ${formatRestDuration(timerState.remainingSeconds)} • '
                              '${details.completedSetsCount}/${details.totalSetsCount} set selesai'
                          : '${details.completedSetsCount}/${details.totalSetsCount} set selesai — Ketuk untuk kembali',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: onTapResume,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Buka Sesi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
