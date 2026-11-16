import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/exercise_library/presentation/exercise_detail_screen.dart';
import '../../features/exercise_library/presentation/exercise_library_screen.dart';
import '../../features/gym_locations/presentation/gym_location_detail_screen.dart';
import '../../features/gym_locations/presentation/gym_locations_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/gyms',
    routes: [
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
          // 2: Plans (Placeholder for Stage 3)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plans',
                builder: (context, state) => const _StagePlaceholderScreen(
                  icon: Icons.event_note_outlined,
                  title: 'Workout Plans',
                  subtitle:
                      'Fitur penyusunan rutinitas latihan & superset akan hadir di Tahap 3.',
                ),
              ),
            ],
          ),
          // 3: Active Workout (Placeholder for Stage 3)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workout',
                builder: (context, state) => const _StagePlaceholderScreen(
                  icon: Icons.play_circle_outline_rounded,
                  title: 'Active Workout',
                  subtitle:
                      'Fitur pencatatan sesi latihan aktif & Smart Rest Timer akan hadir di Tahap 3.',
                ),
              ),
            ],
          ),
          // 4: Analytics (Placeholder for Stage 4)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const _StagePlaceholderScreen(
                  icon: Icons.insights_rounded,
                  title: 'Analytics & PR Engine',
                  subtitle:
                      'Grafik progres 1RM, volume per alat gym, dan tren istirahat akan hadir di Tahap 4.',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Gyms',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Plans',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer_rounded),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

class _StagePlaceholderScreen extends StatelessWidget {
  const _StagePlaceholderScreen({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
