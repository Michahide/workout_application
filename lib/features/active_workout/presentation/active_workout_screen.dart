import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../../../core/database/tables.dart';
import '../../../core/sync/sync_engine.dart';
import '../../analytics/presentation/widgets/exercise_analytics_view.dart';
import '../../exercise_library/presentation/exercise_library_providers.dart';
import '../../exercise_library/presentation/exercise_media_gallery.dart';
import '../../workout_plans/presentation/workout_plans_providers.dart';
import '../data/active_workout_repository.dart';
import '../domain/rest_timer_controller.dart';
import 'floating_rest_timer_bar.dart';
import 'start_workout_gym_sheet.dart';

class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  Future<void> _addExerciseToActiveSession(
    BuildContext context,
    WidgetRef ref,
    ActiveWorkoutSessionDetails sessionDetails,
  ) async {
    final allExercises = await ref.read(allExercisesStreamProvider.future);
    if (!context.mounted) return;

    final chosen =
        await showModalBottomSheet<
          ({Exercise exercise, String? supersetGroupId})
        >(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => _AddSessionExerciseSheet(
            allExercises: allExercises,
            existingExercises: sessionDetails.exercises,
          ),
        );

    if (chosen != null) {
      await ref
          .read(activeWorkoutRepositoryProvider)
          .addExerciseToSession(
            workoutSessionId: sessionDetails.session.id,
            exerciseId: chosen.exercise.id,
            gymLocationId: sessionDetails.session.gymLocationId,
            supersetGroupId: chosen.supersetGroupId,
          );
    }
  }

  Future<void> _confirmFinishWorkout(
    BuildContext context,
    WidgetRef ref,
    ActiveWorkoutSessionDetails details,
  ) async {
    final notesCtrl = TextEditingController(
      text: details.session.sessionNotes ?? '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selesaikan Latihan?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set selesai: ${details.completedSetsCount} dari ${details.totalSetsCount} set.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan Sesi Latihan (Opsional)',
                hintText: 'Contoh: Kondisi prima, progres beban bench press',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Lanjut Latihan'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.check),
            label: const Text('Finish Workout'),
          ),
        ],
      ),
    );

    final notes = notesCtrl.text;
    notesCtrl.dispose();

    if (confirmed == true) {
      await ref.read(restTimerControllerProvider.notifier).resetAll();
      await ref
          .read(activeWorkoutRepositoryProvider)
          .finishWorkoutSession(
            sessionId: details.session.id,
            sessionNotes: notes,
          );
      // Auto-Sync Trigger #3: Non-blocking background sync right after finishing workout
      unawaited(
        ref
            .read(syncControllerProvider.notifier)
            .triggerSyncNow(silentIfUnconfigured: true),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi latihan berhasil disimpan! 💪')),
        );
      }
    }
  }

  Future<void> _confirmDiscardWorkout(
    BuildContext context,
    WidgetRef ref,
    ActiveWorkoutSessionDetails details,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Sesi Latihan?'),
        content: const Text(
          'Sesi aktif ini akan dibatalkan (soft-delete). Tindakan ini tidak disarankan jika Anda sudah mencatat set.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Kembali'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Batalkan Sesi'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(restTimerControllerProvider.notifier).resetAll();
      await ref
          .read(activeWorkoutRepositoryProvider)
          .discardWorkoutSession(details.session.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(activeWorkoutSessionStreamProvider);
    final timerState = ref.watch(restTimerControllerProvider);

    return sessionAsync.when(
      data: (details) {
        if (details == null) {
          return const _IdleWorkoutLauncherView();
        }

        final sessionTitle =
            details.workoutPlan?.name ?? 'Latihan Aktif (Empty Workout)';
        final gymName = details.gymLocation?.name ?? 'Gym Umum';

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 12,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sessionTitle,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined, size: 13),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        gymName,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SessionElapsedClock(startedAt: details.session.startedAt),
                  ],
                ),
              ],
            ),
            actions: [
              FilledButton.icon(
                onPressed: () => _confirmFinishWorkout(context, ref, details),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Finish'),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'settings') {
                    context.push('/settings');
                  } else if (value == 'discard') {
                    _confirmDiscardWorkout(context, ref, details);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.timer_outlined),
                      title: Text('Pengaturan Rest Timer'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'discard',
                    child: ListTile(
                      leading: Icon(Icons.delete_forever_outlined),
                      title: Text('Batalkan Sesi'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: details.exercises.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fitness_center_rounded,
                                size: 56,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Belum ada gerakan di sesi ini.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () => _addExerciseToActiveSession(
                                  context,
                                  ref,
                                  details,
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Gerakan Pertama'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 120),
                        itemCount: details.exercises.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == details.exercises.length) {
                            return OutlinedButton.icon(
                              onPressed: () => _addExerciseToActiveSession(
                                context,
                                ref,
                                details,
                              ),
                              icon: const Icon(Icons.add),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('Tambah Gerakan ke Sesi Ini'),
                              ),
                            );
                          }

                          final bundle = details.exercises[index];
                          final isSupersetFocused =
                              timerState.nextSupersetExerciseId ==
                              bundle.sessionExercise.id;

                          return _ActiveExerciseCard(
                            sessionDetails: details,
                            bundle: bundle,
                            isSupersetFocused: isSupersetFocused,
                          );
                        },
                      ),
              ),
              const FloatingRestTimerBar(),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Gagal memuat sesi latihan: $err')),
      ),
    );
  }
}

class _IdleWorkoutLauncherView extends ConsumerWidget {
  const _IdleWorkoutLauncherView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(workoutPlansWithExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Workout'),
        actions: [
          IconButton(
            tooltip: 'Pengaturan Rest Timer',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Siap Mulai Latihan?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih lokasi gym Anda untuk melacak beban, RPE, dan waktu istirahat nyata per mesin gym.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => StartWorkoutGymSheet.show(context),
                    icon: const Icon(Icons.flash_on_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Start Empty Workout'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Atau Mulai dari Workout Plan',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          plansAsync.when(
            data: (plans) {
              if (plans.isEmpty) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Belum ada Workout Plan'),
                  subtitle: const Text(
                    'Buka tab Plans untuk menyusun rutinitas latihan.',
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => context.go('/plans'),
                    child: const Text('Ke Tab Plans'),
                  ),
                );
              }
              return Column(
                children: plans.map((item) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        item.plan.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${item.exercises.length} gerakan'),
                      trailing: FilledButton.tonalIcon(
                        onPressed: () => StartWorkoutGymSheet.show(
                          context,
                          workoutPlanId: item.plan.id,
                          workoutPlanName: item.plan.name,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text('Start'),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Gagal memuat plan: $e'),
          ),
        ],
      ),
    );
  }
}

class _SessionElapsedClock extends StatefulWidget {
  const _SessionElapsedClock({required this.startedAt});

  final DateTime startedAt;

  @override
  State<_SessionElapsedClock> createState() => _SessionElapsedClockState();
}

class _SessionElapsedClockState extends State<_SessionElapsedClock> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now()
        .toUtc()
        .difference(widget.startedAt.toUtc())
        .inSeconds
        .clamp(0, 86400);
    final hours = elapsed ~/ 3600;
    final mins = (elapsed % 3600) ~/ 60;
    final secs = elapsed % 60;
    final formatted = hours > 0
        ? '$hours:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}'
        : '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Text(
      '• ⏱ $formatted',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ActiveExerciseCard extends ConsumerWidget {
  const _ActiveExerciseCard({
    required this.sessionDetails,
    required this.bundle,
    required this.isSupersetFocused,
  });

  final ActiveWorkoutSessionDetails sessionDetails;
  final ActiveSessionExerciseBundle bundle;
  final bool isSupersetFocused;

  Future<void> _openMediaSheet(BuildContext context) async {
    final machine = bundle.selectedMachine;
    final machineLabel = machine != null
        ? (machine.brandName ?? bundle.exercise.equipmentCategory.label)
        : null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.76,
        maxChildSize: 0.94,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bundle.exercise.name,
                          style: Theme.of(ctx).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          machineLabel != null
                              ? 'Alat Terpilih: $machineLabel (${machine!.weightUnit.label})'
                              : 'Media Umum (Pilih/daftarkan alat di kartu untuk menyimpan media khusus merk mesin)',
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: Theme.of(ctx).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 20),
              ExerciseMediaGallery(
                exerciseId: bundle.exercise.id,
                gymMachineId: machine?.id,
                machineTitle: machineLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMachineSelectorOrQuickRegister(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _QuickMachineSelectorSheet(
        sessionDetails: sessionDetails,
        bundle: bundle,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = bundle.exercise;
    final machine = bundle.selectedMachine;
    final weightUnit = machine?.weightUnit ?? WeightUnit.KG;
    final colorScheme = Theme.of(context).colorScheme;

    final prevPerfAsync = ref.watch(
      previousExercisePerformanceProvider((
        exerciseId: exercise.id,
        gymMachineId: machine?.id,
        excludeSessionId: sessionDetails.session.id,
      )),
    );
    final prevPerf =
        prevPerfAsync.asData?.value ?? PreviousExercisePerformance.empty;

    return Card(
      shape: isSupersetFocused
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colorScheme.tertiary, width: 2),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Header: Superset Badge, Exercise Name, Media Button, Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bundle.supersetBadge != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      bundle.supersetBadge!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${exercise.primaryMuscleGroup.label} (${exercise.muscleSizeCategory.shortLabel}) • ${exercise.exerciseType.label}',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Lihat Grafik Progress & PR Alat Ini',
                  onPressed: () => ExerciseAnalyticsSheet.show(
                    context,
                    exerciseId: exercise.id,
                    gymMachineId: machine?.id,
                  ),
                  icon: const Icon(Icons.insights_rounded, size: 20),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Lihat / Tambah Foto & Video Form',
                  onPressed: () => _openMediaSheet(context),
                  icon: const Icon(Icons.perm_media_outlined, size: 20),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Hapus Gerakan dari Sesi',
                  onPressed: () => ref
                      .read(activeWorkoutRepositoryProvider)
                      .removeExerciseFromSession(bundle.sessionExercise.id),
                  icon: const Icon(Icons.delete_outline, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Machine Selector / Quick Register Bar + Pinned Notes
            InkWell(
              onTap: () => _openMachineSelectorOrQuickRegister(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.7,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          machine != null
                              ? Icons.precision_manufacturing_rounded
                              : Icons.add_circle_outline_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            machine != null
                                ? 'Alat: ${machine.brandName ?? exercise.equipmentCategory.label}'
                                : 'Belum ada mesin terdaftar di gym ini — Ketuk untuk Quick Register',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            weightUnit.label,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.swap_horiz_rounded, size: 16),
                      ],
                    ),
                    if (machine?.pinnedNotes != null &&
                        machine!.pinnedNotes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '📌 ${machine.pinnedNotes}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Column Headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  const SizedBox(
                    width: 36,
                    child: Text(
                      'SET',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'HISTORI ALAT',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      _inputColumnsHeader(exercise.exerciseType, weightUnit),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 66,
                    child: Text(
                      'RPE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 34, child: Icon(Icons.check, size: 15)),
                ],
              ),
            ),
            const Divider(height: 10),

            // Set Rows
            ...bundle.sets.map((setRow) {
              final prevSet = prevPerf.forSet(setRow.setNumber);
              return _WorkoutSetRow(
                key: ValueKey(setRow.id),
                sessionDetails: sessionDetails,
                bundle: bundle,
                workoutSet: setRow,
                previousSet: prevSet,
                weightUnit: weightUnit,
              );
            }),

            const SizedBox(height: 8),

            // Add Set & Add Drop Set Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => ref
                        .read(activeWorkoutRepositoryProvider)
                        .addSet(
                          sessionExerciseId: bundle.sessionExercise.id,
                          muscleSizeCategory: exercise.muscleSizeCategory,
                          customExerciseRestSeconds:
                              exercise.defaultWorkingRestSeconds,
                          setType: SetType.normal,
                        ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Set'),
                  ),
                ),
                if (bundle.sets.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      final lastSet = bundle.sets.last;
                      ref
                          .read(activeWorkoutRepositoryProvider)
                          .addSet(
                            sessionExerciseId: bundle.sessionExercise.id,
                            muscleSizeCategory: exercise.muscleSizeCategory,
                            customExerciseRestSeconds:
                                exercise.defaultWorkingRestSeconds,
                            setType: SetType.dropset,
                            parentSetId: lastSet.parentSetId ?? lastSet.id,
                            parentSetNumber: lastSet.setNumber,
                          );
                    },
                    icon: const Icon(Icons.subdirectory_arrow_right, size: 18),
                    label: const Text('+ Sub-Drop Set'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _inputColumnsHeader(ExerciseType type, WeightUnit unit) {
    final u = unit.label;
    return switch (type) {
      ExerciseType.weight_reps => '$u × REPS',
      ExerciseType.bodyweight_reps => 'BW × REPS',
      ExerciseType.weighted_bodyweight => '+$u × REPS',
      ExerciseType.assisted_bodyweight => '-$u × REPS',
      ExerciseType.duration => 'DETIK',
      ExerciseType.duration_weight => '$u × DETIK',
      ExerciseType.distance_duration => 'METER × DETIK',
      ExerciseType.weight_distance => '$u × METER',
    };
  }
}

class _WorkoutSetRow extends ConsumerStatefulWidget {
  const _WorkoutSetRow({
    super.key,
    required this.sessionDetails,
    required this.bundle,
    required this.workoutSet,
    required this.previousSet,
    required this.weightUnit,
  });

  final ActiveWorkoutSessionDetails sessionDetails;
  final ActiveSessionExerciseBundle bundle;
  final WorkoutSet workoutSet;
  final PreviousSetPerformance? previousSet;
  final WeightUnit weightUnit;

  @override
  ConsumerState<_WorkoutSetRow> createState() => _WorkoutSetRowState();
}

class _WorkoutSetRowState extends ConsumerState<_WorkoutSetRow> {
  late final TextEditingController _primaryInputCtrl;
  late final TextEditingController _secondaryInputCtrl;

  @override
  void initState() {
    super.initState();
    _primaryInputCtrl = TextEditingController(text: _initialPrimaryText());
    _secondaryInputCtrl = TextEditingController(text: _initialSecondaryText());
  }

  @override
  void didUpdateWidget(covariant _WorkoutSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newPrimary = _initialPrimaryText();
    if (_primaryInputCtrl.text != newPrimary &&
        !FocusScope.of(context).hasFocus) {
      _primaryInputCtrl.text = newPrimary;
    }
    final newSecondary = _initialSecondaryText();
    if (_secondaryInputCtrl.text != newSecondary &&
        !FocusScope.of(context).hasFocus) {
      _secondaryInputCtrl.text = newSecondary;
    }
  }

  @override
  void dispose() {
    _primaryInputCtrl.dispose();
    _secondaryInputCtrl.dispose();
    super.dispose();
  }

  String _formatDouble(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  String _initialPrimaryText() {
    final s = widget.workoutSet;
    return switch (widget.bundle.exercise.exerciseType) {
      ExerciseType.weight_reps ||
      ExerciseType.weighted_bodyweight ||
      ExerciseType.assisted_bodyweight ||
      ExerciseType.duration_weight ||
      ExerciseType.weight_distance => _formatDouble(s.weight),
      ExerciseType.bodyweight_reps => s.reps?.toString() ?? '',
      ExerciseType.duration => s.durationSeconds?.toString() ?? '',
      ExerciseType.distance_duration => _formatDouble(s.distanceMeters),
    };
  }

  String _initialSecondaryText() {
    final s = widget.workoutSet;
    return switch (widget.bundle.exercise.exerciseType) {
      ExerciseType.weight_reps ||
      ExerciseType.weighted_bodyweight ||
      ExerciseType.assisted_bodyweight => s.reps?.toString() ?? '',
      ExerciseType.duration_weight ||
      ExerciseType.distance_duration => s.durationSeconds?.toString() ?? '',
      ExerciseType.weight_distance => _formatDouble(s.distanceMeters),
      ExerciseType.bodyweight_reps || ExerciseType.duration => '',
    };
  }

  Future<void> _persistInputs() async {
    final repo = ref.read(activeWorkoutRepositoryProvider);
    final type = widget.bundle.exercise.exerciseType;
    final pText = _primaryInputCtrl.text.trim();
    final sText = _secondaryInputCtrl.text.trim();

    switch (type) {
      case ExerciseType.weight_reps:
      case ExerciseType.weighted_bodyweight:
      case ExerciseType.assisted_bodyweight:
        await repo.updateSet(
          setId: widget.workoutSet.id,
          weight: Value(double.tryParse(pText)),
          reps: Value(int.tryParse(sText)),
        );
      case ExerciseType.bodyweight_reps:
        await repo.updateSet(
          setId: widget.workoutSet.id,
          reps: Value(int.tryParse(pText)),
        );
      case ExerciseType.duration:
        await repo.updateSet(
          setId: widget.workoutSet.id,
          durationSeconds: Value(int.tryParse(pText)),
        );
      case ExerciseType.duration_weight:
        await repo.updateSet(
          setId: widget.workoutSet.id,
          weight: Value(double.tryParse(pText)),
          durationSeconds: Value(int.tryParse(sText)),
        );
      case ExerciseType.distance_duration:
        await repo.updateSet(
          setId: widget.workoutSet.id,
          distanceMeters: Value(double.tryParse(pText)),
          durationSeconds: Value(int.tryParse(sText)),
        );
      case ExerciseType.weight_distance:
        await repo.updateSet(
          setId: widget.workoutSet.id,
          weight: Value(double.tryParse(pText)),
          distanceMeters: Value(double.tryParse(sText)),
        );
    }
  }

  Future<void> _copyFromPreviousPerformance() async {
    final prev = widget.previousSet;
    if (prev == null) return;

    await ref
        .read(activeWorkoutRepositoryProvider)
        .updateSet(
          setId: widget.workoutSet.id,
          weight: Value(prev.weight),
          reps: Value(prev.reps),
          durationSeconds: Value(prev.durationSeconds),
          distanceMeters: Value(prev.distanceMeters),
        );

    setState(() {
      if (prev.weight != null) {
        _primaryInputCtrl.text = _formatDouble(prev.weight);
      }
      if (prev.reps != null) {
        if (widget.bundle.exercise.exerciseType ==
            ExerciseType.bodyweight_reps) {
          _primaryInputCtrl.text = prev.reps.toString();
        } else {
          _secondaryInputCtrl.text = prev.reps.toString();
        }
      }
    });
  }

  Future<void> _cycleOrPickSetType() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Pilih Tipe Set (Set #${widget.workoutSet.setNumber})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...SetType.values.map(
              (t) => ListTile(
                leading: _SetBadgeAvatar(
                  setType: t,
                  setNumber: widget.workoutSet.setNumber,
                  isSubDrop: widget.workoutSet.parentSetId != null,
                ),
                title: Text(t.label),
                onTap: () => Navigator.of(ctx).pop(t.name),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Hapus Baris Set Ini'),
              onTap: () => Navigator.of(ctx).pop('DELETE_SET'),
            ),
          ],
        ),
      ),
    );

    if (selected == null) return;
    if (selected == 'DELETE_SET') {
      await ref
          .read(activeWorkoutRepositoryProvider)
          .softDeleteSet(widget.workoutSet.id);
      return;
    }

    final newType = SetType.values.byName(selected);
    await ref
        .read(activeWorkoutRepositoryProvider)
        .updateSet(setId: widget.workoutSet.id, setType: newType);
  }

  Future<void> _openRpeAndSpotterPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          _RpeAssistanceRestPickerSheet(workoutSet: widget.workoutSet),
    );
  }

  Future<void> _toggleComplete(bool? checked) async {
    await _persistInputs();
    final isCompleting = checked ?? false;
    final repo = ref.read(activeWorkoutRepositoryProvider);
    final restController = ref.read(restTimerControllerProvider.notifier);

    if (isCompleting) {
      final elapsedActualRest =
          widget.workoutSet.actualRestSeconds ??
          restController.computeActualRestSeconds();

      final resolvedTargetRest = await restController.onSetCompleted(
        sessionDetails: widget.sessionDetails,
        currentExerciseBundle: widget.bundle,
        completedSetNumber: widget.workoutSet.setNumber,
        completedSetType: widget.workoutSet.setType,
        customSetTargetRestSeconds: widget.workoutSet.targetRestSeconds,
      );

      await repo.completeSet(
        setId: widget.workoutSet.id,
        isCompleted: true,
        targetRestSeconds: resolvedTargetRest,
        actualRestSeconds: elapsedActualRest,
      );
    } else {
      await repo.completeSet(setId: widget.workoutSet.id, isCompleted: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.workoutSet;
    final prev = widget.previousSet;
    final exType = widget.bundle.exercise.exerciseType;
    final isSingleInput =
        exType == ExerciseType.bodyweight_reps ||
        exType == ExerciseType.duration;
    final isSubDrop = s.parentSetId != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 4, bottom: 4, left: isSubDrop ? 16 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: s.isCompleted
            ? colorScheme.primaryContainer.withValues(alpha: 0.35)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Col 1: Set Type & Number Badge
              InkWell(
                onTap: _cycleOrPickSetType,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 36,
                  child: Center(
                    child: _SetBadgeAvatar(
                      setType: s.setType,
                      setNumber: s.setNumber,
                      isSubDrop: isSubDrop,
                    ),
                  ),
                ),
              ),

              // Col 2: Inline Previous Performance (Tap to copy)
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: prev != null ? _copyFromPreviousPerformance : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Text(
                      prev != null ? prev.formatInline(exType) : '—',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: prev?.isFromOtherGym == true
                            ? colorScheme.tertiary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: prev != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),

              // Col 3 & 4: Dynamic Weight/Reps/Duration/Distance Inputs
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _primaryInputCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            hintText: isSingleInput ? '0' : '0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (_) => _persistInputs(),
                        ),
                      ),
                    ),
                    if (!isSingleInput) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: TextField(
                            controller: _secondaryInputCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 6,
                              ),
                              hintText: '0',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (_) => _persistInputs(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Col 5: RPE & Spotter/Assistance Badge
              InkWell(
                onTap: _openRpeAndSpotterPicker,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 64,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: s.assistanceType == AssistanceType.assisted
                        ? colorScheme.errorContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        s.rpe != null ? 'RPE ${s.rpe}' : 'RPE —',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: s.assistanceType == AssistanceType.assisted
                              ? colorScheme.onErrorContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (s.assistanceType == AssistanceType.assisted)
                            Icon(
                              Icons.supervisor_account_rounded,
                              size: 11,
                              color: colorScheme.onErrorContainer,
                            ),
                          Flexible(
                            child: Text(
                              s.assistanceType.label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                color:
                                    s.assistanceType == AssistanceType.assisted
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Col 6: Checkbox Complete
              SizedBox(
                width: 34,
                child: Checkbox(
                  value: s.isCompleted,
                  onChanged: _toggleComplete,
                ),
              ),
            ],
          ),

          // Actual vs Target Rest Pill (Editable on tap)
          if (s.actualRestSeconds != null || s.isCompleted)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 2),
              child: InkWell(
                onTap: _openRpeAndSpotterPicker,
                child: Text(
                  '⏱ Actual Rest: ${s.actualRestSeconds != null ? formatCompactDuration(s.actualRestSeconds!) : "0s"} '
                  '(Target: ${formatCompactDuration(s.targetRestSeconds ?? 180)}) • Ketuk untuk ubah',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(fontSize: 10, color: colorScheme.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SetBadgeAvatar extends StatelessWidget {
  const _SetBadgeAvatar({
    required this.setType,
    required this.setNumber,
    required this.isSubDrop,
  });

  final SetType setType;
  final int setNumber;
  final bool isSubDrop;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, text) = switch (setType) {
      SetType.warmup => (Colors.amber.shade700, Colors.white, 'W'),
      SetType.normal => (
        Theme.of(context).colorScheme.secondaryContainer,
        Theme.of(context).colorScheme.onSecondaryContainer,
        '$setNumber',
      ),
      SetType.dropset => (
        Colors.deepPurple.shade600,
        Colors.white,
        isSubDrop ? '↳D' : 'D',
      ),
      SetType.failure => (Colors.red.shade700, Colors.white, 'F'),
    };

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Compact bottom sheet for selecting RPE (`6.0` - `10.0` in `0.5` steps),
/// Assistance Type (`Solo`, `Spotted`, `Assisted`), and manually editing
/// `actualRestSeconds` / `targetRestSeconds`.
class _RpeAssistanceRestPickerSheet extends ConsumerStatefulWidget {
  const _RpeAssistanceRestPickerSheet({required this.workoutSet});

  final WorkoutSet workoutSet;

  @override
  ConsumerState<_RpeAssistanceRestPickerSheet> createState() =>
      _RpeAssistanceRestPickerSheetState();
}

class _RpeAssistanceRestPickerSheetState
    extends ConsumerState<_RpeAssistanceRestPickerSheet> {
  static const List<double> _rpeSteps = [
    6.0,
    6.5,
    7.0,
    7.5,
    8.0,
    8.5,
    9.0,
    9.5,
    10.0,
  ];

  double? _selectedRpe;
  late AssistanceType _selectedAssistance;
  late final TextEditingController _actualRestCtrl;
  late final TextEditingController _targetRestCtrl;

  @override
  void initState() {
    super.initState();
    _selectedRpe = widget.workoutSet.rpe;
    _selectedAssistance = widget.workoutSet.assistanceType;
    _actualRestCtrl = TextEditingController(
      text: widget.workoutSet.actualRestSeconds?.toString() ?? '',
    );
    _targetRestCtrl = TextEditingController(
      text: widget.workoutSet.targetRestSeconds?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _actualRestCtrl.dispose();
    _targetRestCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final actualText = _actualRestCtrl.text.trim();
    final targetText = _targetRestCtrl.text.trim();

    await ref
        .read(activeWorkoutRepositoryProvider)
        .updateSet(
          setId: widget.workoutSet.id,
          rpe: Value(_selectedRpe),
          assistanceType: _selectedAssistance,
          actualRestSeconds: Value(
            actualText.isEmpty ? null : int.tryParse(actualText),
          ),
          targetRestSeconds: Value(
            targetText.isEmpty ? null : int.tryParse(targetText),
          ),
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'RPE, Spotter & Waktu Istirahat (Set #${widget.workoutSet.setNumber})',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'RPE (Rate of Perceived Exertion)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Tanpa RPE'),
                  selected: _selectedRpe == null,
                  onSelected: (_) => setState(() => _selectedRpe = null),
                ),
                ..._rpeSteps.map(
                  (rpeVal) => ChoiceChip(
                    label: Text(rpeVal.toStringAsFixed(1)),
                    selected: _selectedRpe == rpeVal,
                    onSelected: (_) => setState(() => _selectedRpe = rpeVal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Status Spotter / Assistance',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            ...AssistanceType.values.map((type) {
              final isSelected = _selectedAssistance == type;
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  dense: true,
                  onTap: () => setState(() => _selectedAssistance = type),
                  leading: Icon(switch (type) {
                    AssistanceType.solo => Icons.person_outline,
                    AssistanceType.spotted_no_touch => Icons.shield_outlined,
                    AssistanceType.assisted => Icons.supervisor_account_rounded,
                  }),
                  title: Text(
                    type.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(type.description),
                  trailing: isSelected ? const Icon(Icons.check_circle) : null,
                ),
              );
            }),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _actualRestCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Actual Rest (Detik)',
                      hintText: 'Contoh: 135',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _targetRestCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Rest (Detik)',
                      hintText: 'Contoh: 180',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Simpan Detail Set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal allowing the user to switch between registered machines at the current gym
/// OR quick-register a brand-new machine (`brandName`, `weightUnit`, `pinnedNotes`)
/// in 1 tap without leaving the Active Workout screen.
class _QuickMachineSelectorSheet extends ConsumerStatefulWidget {
  const _QuickMachineSelectorSheet({
    required this.sessionDetails,
    required this.bundle,
  });

  final ActiveWorkoutSessionDetails sessionDetails;
  final ActiveSessionExerciseBundle bundle;

  @override
  ConsumerState<_QuickMachineSelectorSheet> createState() =>
      _QuickMachineSelectorSheetState();
}

class _QuickMachineSelectorSheetState
    extends ConsumerState<_QuickMachineSelectorSheet> {
  final _brandCtrl = TextEditingController();
  final _pinnedNotesCtrl = TextEditingController();
  WeightUnit _weightUnit = WeightUnit.KG;
  bool _isSaving = false;

  @override
  void dispose() {
    _brandCtrl.dispose();
    _pinnedNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectExistingMachine(String? machineId) async {
    await ref
        .read(activeWorkoutRepositoryProvider)
        .assignMachineToSessionExercise(
          sessionExerciseId: widget.bundle.sessionExercise.id,
          gymMachineId: machineId,
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _quickRegisterNewMachine() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(activeWorkoutRepositoryProvider)
          .quickRegisterAndAssignMachine(
            sessionExerciseId: widget.bundle.sessionExercise.id,
            exerciseId: widget.bundle.exercise.id,
            gymLocationId: widget.sessionDetails.session.gymLocationId,
            brandName: _brandCtrl.text.trim().isEmpty
                ? widget.bundle.exercise.equipmentCategory.label
                : _brandCtrl.text.trim(),
            weightUnit: _weightUnit,
            pinnedNotes: _pinnedNotesCtrl.text,
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = widget.bundle.availableMachinesAtGym;
    final selectedId = widget.bundle.selectedMachine?.id;
    final gymName = widget.sessionDetails.gymLocation?.name ?? 'Gym Ini';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Alat untuk ${widget.bundle.exercise.name}',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            if (available.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Pilih Alat Terdaftar di $gymName:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              ...available.map((m) {
                final isSelected = m.id == selectedId;
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    onTap: () => _selectExistingMachine(m.id),
                    title: Text(
                      m.brandName ??
                          widget.bundle.exercise.equipmentCategory.label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: m.pinnedNotes != null
                        ? Text('📌 ${m.pinnedNotes}')
                        : null,
                    trailing: Chip(
                      label: Text(m.weightUnit.label),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                );
              }),
              const Divider(height: 24),
            ],

            Text(
              'Quick Register Alat Baru di $gymName',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _brandCtrl,
              decoration: const InputDecoration(
                labelText: 'Merk & Identitas Mesin *',
                hintText: 'Contoh: Hoist, Technogym #1 (Pojok), Technogym #2',
                helperText: 'Foto, video, working set, dan 1RM akan diikat khusus ke mesin ini.',
                helperMaxLines: 2,
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<WeightUnit>(
              segments: WeightUnit.values
                  .map(
                    (u) => ButtonSegment<WeightUnit>(
                      value: u,
                      label: Text(u.label),
                    ),
                  )
                  .toList(),
              selected: {_weightUnit},
              onSelectionChanged: (sel) =>
                  setState(() => _weightUnit = sel.first),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pinnedNotesCtrl,
              decoration: const InputDecoration(
                labelText: 'Pinned Notes (Setting Kursi / Pin)',
                hintText: 'Contoh: Kursi level 5, handle tengah',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _isSaving ? null : _quickRegisterNewMachine,
              icon: const Icon(Icons.add_task_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Quick Register & Gunakan Alat Ini'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSessionExerciseSheet extends StatefulWidget {
  const _AddSessionExerciseSheet({
    required this.allExercises,
    required this.existingExercises,
  });

  final List<Exercise> allExercises;
  final List<ActiveSessionExerciseBundle> existingExercises;

  @override
  State<_AddSessionExerciseSheet> createState() =>
      _AddSessionExerciseSheetState();
}

class _AddSessionExerciseSheetState extends State<_AddSessionExerciseSheet> {
  String _search = '';
  bool _pairWithLastExercise = false;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.allExercises
        .where((e) {
          if (_search.trim().isEmpty) return true;
          return e.name.toLowerCase().contains(_search.trim().toLowerCase());
        })
        .toList(growable: false);

    final lastExercise = widget.existingExercises.isNotEmpty
        ? widget.existingExercises.last
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tambah Gerakan ke Sesi',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (lastExercise != null)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _pairWithLastExercise,
              onChanged: (v) =>
                  setState(() => _pairWithLastExercise = v ?? false),
              title: Text(
                'Gabungkan Superset dengan "${lastExercise.exercise.name}"',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          TextField(
            autofocus: true,
            onChanged: (val) => setState(() => _search = val),
            decoration: const InputDecoration(
              hintText: 'Cari nama gerakan...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final ex = filtered[index];
                return ListTile(
                  title: Text(
                    ex.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${ex.primaryMuscleGroup.label} • ${ex.equipmentCategory.label}',
                  ),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () {
                    String? supersetId;
                    if (_pairWithLastExercise && lastExercise != null) {
                      supersetId =
                          lastExercise.sessionExercise.supersetGroupId ??
                          'ss_${lastExercise.sessionExercise.id.substring(0, 6)}';
                    }
                    Navigator.of(context)
                        .pop((exercise: ex, supersetGroupId: supersetId));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
