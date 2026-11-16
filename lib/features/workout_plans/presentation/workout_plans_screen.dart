import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../active_workout/data/active_workout_repository.dart';
import '../../active_workout/presentation/start_workout_gym_sheet.dart';
import '../data/workout_plan_repository.dart';
import 'workout_plan_form_screen.dart';
import 'workout_plans_providers.dart';

class WorkoutPlansScreen extends ConsumerWidget {
  const WorkoutPlansScreen({super.key});

  Future<void> _openPlanForm(
    BuildContext context, {
    WorkoutPlanWithExercises? existingPlan,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => WorkoutPlanFormScreen(existingPlan: existingPlan),
      ),
    );
  }

  Future<void> _startWorkout(
    BuildContext context, {
    String? workoutPlanId,
    String? workoutPlanName,
  }) async {
    final started = await StartWorkoutGymSheet.show(
      context,
      workoutPlanId: workoutPlanId,
      workoutPlanName: workoutPlanName,
    );
    if (started && context.mounted) {
      context.go('/workout');
    }
  }

  Future<void> _confirmDeletePlan(
    BuildContext context,
    WidgetRef ref,
    WorkoutPlanWithExercises item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Workout Plan?'),
        content: Text(
          'Hapus "${item.plan.name}" secara soft-delete?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(workoutPlanRepositoryProvider)
          .softDeleteWorkoutPlan(item.plan.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(workoutPlansWithExercisesProvider);
    final activeSessionAsync = ref.watch(activeWorkoutSessionStreamProvider);
    final hasActiveSession = activeSessionAsync.asData?.value != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plans'),
        actions: [
          IconButton(
            tooltip: 'Pengaturan Rest Timer',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Buat Plan Baru',
            onPressed: () => _openPlanForm(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Quick Start Empty Workout / Resume Active Workout Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Card(
                color: hasActiveSession
                    ? colorScheme.tertiaryContainer
                    : colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasActiveSession
                                  ? 'Sesi Latihan Sedang Berlangsung'
                                  : 'Latihan Bebas (Empty Workout)',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: hasActiveSession
                                        ? colorScheme.onTertiaryContainer
                                        : colorScheme.onPrimaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasActiveSession
                                  ? 'Ketuk untuk kembali mencatat set pada sesi aktif Anda.'
                                  : 'Mulai latihan langsung tanpa template rutinitas.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: hasActiveSession
                                        ? colorScheme.onTertiaryContainer
                                        : colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () {
                          if (hasActiveSession) {
                            context.go('/workout');
                          } else {
                            _startWorkout(context);
                          }
                        },
                        icon: Icon(
                          hasActiveSession
                              ? Icons.play_circle_fill_rounded
                              : Icons.flash_on_rounded,
                        ),
                        label: Text(
                          hasActiveSession
                              ? 'Resume'
                              : 'Start Empty Workout',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rutinitas Latihan Saya',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openPlanForm(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Buat Plan'),
                  ),
                ],
              ),
            ),
          ),

          plansAsync.when(
            data: (plans) {
              if (plans.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            size: 56,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada Workout Plan tersimpan.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Susun rutinitas seperti Push Day, Pull Day, atau Upper/Lower lengkap dengan urutan gerakan dan Superset.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: () => _openPlanForm(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Buat Plan Pertama'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                sliver: SliverList.separated(
                  itemCount: plans.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = plans[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.plan.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit Plan',
                                  onPressed: () => _openPlanForm(
                                    context,
                                    existingPlan: item,
                                  ),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Hapus Plan',
                                  onPressed: () =>
                                      _confirmDeletePlan(context, ref, item),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                            if (item.plan.notes != null) ...[
                              Text(
                                item.plan.notes!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            const SizedBox(height: 6),
                            ...item.exercises.map((exItem) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: Row(
                                  children: [
                                    if (exItem.supersetBadge != null)
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.tertiaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          exItem.supersetBadge!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onTertiaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        exItem.exercise.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                    Text(
                                      '${exItem.planExercise.targetSets} × ${exItem.planExercise.targetReps ?? "-"}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () {
                                  if (hasActiveSession) {
                                    context.go('/workout');
                                  } else {
                                    _startWorkout(
                                      context,
                                      workoutPlanId: item.plan.id,
                                      workoutPlanName: item.plan.name,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: Text(
                                  hasActiveSession
                                      ? 'Sesi Aktif Sedang Berjalan (Lihat)'
                                      : 'Start Workout',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Gagal memuat Workout Plans: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPlanForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Buat Plan'),
      ),
    );
  }
}
