import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/domain_labels.dart';
import '../../../exercise_library/presentation/exercise_library_providers.dart';
import '../../../exercise_library/presentation/exercise_media_gallery.dart';
import '../../../gym_locations/data/gym_location_repository.dart';
import '../../../gym_locations/presentation/gym_locations_providers.dart';
import '../../../gym_locations/presentation/machine_thumbnail_avatar.dart';
import '../../data/analytics_repository.dart';
import '../analytics_providers.dart';
import 'exercise_progression_chart.dart';
import 'pr_bento_grid.dart';

/// Modal bottom sheet wrapper that opens Exercise Progress & PRs pre-filtered
/// for a specific [exerciseId] and optional [gymMachineId] (used from Active Workout
/// and Exercise Detail screens).
class ExerciseAnalyticsSheet extends StatelessWidget {
  const ExerciseAnalyticsSheet({
    super.key,
    required this.exerciseId,
    this.initialGymMachineId,
  });

  final String exerciseId;
  final String? initialGymMachineId;

  static Future<void> show(
    BuildContext context, {
    required String exerciseId,
    String? gymMachineId,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        maxChildSize: 0.96,
        minChildSize: 0.5,
        builder: (ctx, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  const Icon(Icons.insights_rounded),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Progress & Personal Records (PR)',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ExerciseAnalyticsView(
                initialExerciseId: exerciseId,
                initialGymMachineId: gymMachineId,
                lockExerciseSelection: true,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseAnalyticsView(
      initialExerciseId: exerciseId,
      initialGymMachineId: initialGymMachineId,
      lockExerciseSelection: true,
    );
  }
}

/// Interactive view for Sub-tab 1: Exercise Progress & PRs.
class ExerciseAnalyticsView extends ConsumerStatefulWidget {
  const ExerciseAnalyticsView({
    super.key,
    this.initialExerciseId,
    this.initialGymMachineId,
    this.lockExerciseSelection = false,
    this.scrollController,
  });

  final String? initialExerciseId;
  final String? initialGymMachineId;
  final bool lockExerciseSelection;
  final ScrollController? scrollController;

  @override
  ConsumerState<ExerciseAnalyticsView> createState() =>
      _ExerciseAnalyticsViewState();
}

class _ExerciseAnalyticsViewState extends ConsumerState<ExerciseAnalyticsView> {
  String? _selectedExerciseId;
  String? _selectedGymMachineId;
  bool _hasResolvedDefaultMachine = false;
  bool _includeAssistedSets = false;
  AnalyticsDateRange _dateRange = AnalyticsDateRange.allTime;
  AnalyticsChartMetric _chartMetric = AnalyticsChartMetric.estimated1RM;

  @override
  void initState() {
    super.initState();
    _selectedExerciseId = widget.initialExerciseId;
    _selectedGymMachineId = widget.initialGymMachineId;
    _hasResolvedDefaultMachine = widget.initialGymMachineId != null;
  }

  Future<void> _pickExerciseDialog(List<Exercise> exercises) async {
    final chosen = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _QuickExerciseSearchSheet(exercises: exercises),
    );

    if (chosen != null) {
      final defaultMachineId = await ref
          .read(analyticsRepositoryProvider)
          .getMostRecentMachineIdForExercise(chosen.id);
      if (mounted) {
        setState(() {
          _selectedExerciseId = chosen.id;
          _selectedGymMachineId = defaultMachineId;
          _hasResolvedDefaultMachine = true;
        });
      }
    }
  }

  Future<void> _openVisualMachineFilterSheet({
    required String exerciseId,
    required List<GymMachineWithDetails> machines,
    required String? currentMachineId,
  }) async {
    final result = await showModalBottomSheet<({bool selected, String? id})>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _VisualMachineFilterPickerSheet(
        exerciseId: exerciseId,
        machines: machines,
        selectedMachineId: currentMachineId,
      ),
    );

    if (result != null && result.selected) {
      setState(() {
        _selectedExerciseId = exerciseId;
        _selectedGymMachineId = result.id;
        _hasResolvedDefaultMachine = true;
      });
    }
  }

  String _formatMachineLabel(GymMachineWithDetails item) {
    final gymName = item.gymLocation?.name ?? 'Global';
    final brand =
        item.machine.brandName ?? item.exercise.equipmentCategory.label;
    return '$gymName - $brand (${item.machine.weightUnit.label})';
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(allExercisesStreamProvider);

    return exercisesAsync.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return const Center(
            child: Text('Belum ada gerakan di Exercise Library.'),
          );
        }

        final activeExercise = exercises
                .where((e) => e.id == _selectedExerciseId)
                .firstOrNull ??
            exercises.first;

        final effectiveExerciseId = activeExercise.id;
        final machinesAsync = ref.watch(
          gymMachinesByExerciseProvider(effectiveExerciseId),
        );
        final recentMachineAsync = ref.watch(
          mostRecentMachineForExerciseProvider(effectiveExerciseId),
        );

        // Auto-select most recently used machine on initial load if not yet set
        String? effectiveMachineId = _selectedGymMachineId;
        if (!_hasResolvedDefaultMachine && recentMachineAsync.hasValue) {
          effectiveMachineId = recentMachineAsync.value;
        }

        final filter = AnalyticsFilter(
          exerciseId: effectiveExerciseId,
          gymMachineId: effectiveMachineId,
          includeAssistedSets: _includeAssistedSets,
          dateRange: _dateRange,
        );

        final prSummaryAsync = ref.watch(exercisePRSummaryProvider(filter));
        final seriesAsync = ref.watch(
          exerciseProgressionSeriesProvider(filter),
        );

        return ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            // 1. Exercise Selector Card
            if (!widget.lockExerciseSelection) ...[
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => _pickExerciseDialog(exercises),
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    activeExercise.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${activeExercise.primaryMuscleGroup.label} • ${activeExercise.equipmentCategory.label} • ${activeExercise.exerciseType.label}',
                  ),
                  trailing: const Chip(
                    label: Text('Ganti'),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ] else ...[
              Text(
                activeExercise.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
            ],

            // 2. Visual Machine at Gym Filter Card (with Photo Thumbnail Preview!) + Solo vs Assisted Toggle
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filter Spesifik Alat & Lokasi Gym',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    machinesAsync.when(
                      data: (machines) {
                        final selectedItem = machines
                            .where((m) => m.machine.id == effectiveMachineId)
                            .firstOrNull;
                        final validMachineId = selectedItem?.machine.id;
                        final colorScheme = Theme.of(context).colorScheme;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Active Selected Machine Card with Photo Preview
                            InkWell(
                              onTap: () => _openVisualMachineFilterSheet(
                                exerciseId: effectiveExerciseId,
                                machines: machines,
                                currentMachineId: validMachineId,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    MachineThumbnailAvatar(
                                      exerciseId: effectiveExerciseId,
                                      gymMachineId: validMachineId,
                                      size: 56,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: selectedItem != null
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  selectedItem.machine.brandName ??
                                                      selectedItem
                                                          .exercise
                                                          .equipmentCategory
                                                          .label,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '📍 ${selectedItem.gymLocation?.name ?? "Global (Semua Gym)"} • ${selectedItem.machine.weightUnit.label}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            colorScheme.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                if (selectedItem
                                                            .machine
                                                            .pinnedNotes !=
                                                        null &&
                                                    selectedItem
                                                        .machine
                                                        .pinnedNotes!
                                                        .isNotEmpty)
                                                  Text(
                                                    '📌 ${selectedItem.machine.pinnedNotes}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.labelSmall,
                                                  ),
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Semua Alat / Global (Semua Gym)',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  machines.isEmpty
                                                      ? 'Belum ada mesin spesifik terdaftar untuk gerakan ini'
                                                      : 'Ketuk untuk memilih 1 dari ${machines.length} alat terdaftar beserta preview fotonya',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.expand_more_rounded),
                                  ],
                                ),
                              ),
                            ),

                            // Horizontal Visual Machine Strip (Quick 1-Tap Switch with Photo Previews)
                            if (machines.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 68,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: machines.length + 1,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, idx) {
                                    if (idx == 0) {
                                      final isGlobalSelected =
                                          validMachineId == null;
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedExerciseId =
                                                effectiveExerciseId;
                                            _selectedGymMachineId = null;
                                            _hasResolvedDefaultMachine = true;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isGlobalSelected
                                                ? colorScheme.primaryContainer
                                                : colorScheme
                                                    .surfaceContainerHighest
                                                    .withValues(alpha: 0.5),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: isGlobalSelected
                                                ? Border.all(
                                                    color: colorScheme.primary,
                                                    width: 1.5,
                                                  )
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.public_rounded,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Semua\nAlat',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    final item = machines[idx - 1];
                                    final isSelected =
                                        item.machine.id == validMachineId;
                                    final brand = item.machine.brandName ??
                                        item.exercise.equipmentCategory.label;
                                    final gymName =
                                        item.gymLocation?.name ?? 'Global';

                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedExerciseId =
                                              effectiveExerciseId;
                                          _selectedGymMachineId =
                                              item.machine.id;
                                          _hasResolvedDefaultMachine = true;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colorScheme.primaryContainer
                                              : colorScheme
                                                  .surfaceContainerHighest
                                                  .withValues(alpha: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: isSelected
                                              ? Border.all(
                                                  color: colorScheme.primary,
                                                  width: 1.5,
                                                )
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            MachineThumbnailAvatar(
                                              exerciseId: effectiveExerciseId,
                                              gymMachineId: item.machine.id,
                                              size: 52,
                                            ),
                                            const SizedBox(width: 8),
                                            ConstrainedBox(
                                              constraints:
                                                  const BoxConstraints(
                                                    maxWidth: 120,
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    brand,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  Text(
                                                    '$gymName (${item.machine.weightUnit.label})',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.labelSmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Gagal memuat mesin: $e'),
                    ),
                    const Divider(height: 16),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _includeAssistedSets
                            ? 'Mode: Include Assisted Sets (Semua Set)'
                            : 'Mode: Solo Only (Murni Tanpa Bantuan Spotter)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        _includeAssistedSets
                            ? 'Menyertakan set yang dibantu angkat oleh spotter (ditandai lingkaran oranye).'
                            : 'Hanya menghitung set Solo & Spotted No-Touch untuk akurasi PR murni.',
                        style: const TextStyle(fontSize: 11),
                      ),
                      value: _includeAssistedSets,
                      onChanged: (val) =>
                          setState(() => _includeAssistedSets = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 3. PR Bento Grid (4 Cards)
            Text(
              'Personal Records (All-Time)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            prSummaryAsync.when(
              data: (summary) {
                if (summary == null) {
                  return const SizedBox.shrink();
                }
                return PRBentoGrid(summary: summary);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text('Gagal memuat PR: $err'),
            ),
            const SizedBox(height: 16),

            // 4. Interactive fl_chart Progression Section
            Text(
              'Grafik Progres Latihan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            seriesAsync.when(
              data: (points) => ExerciseProgressionChart(
                points: points,
                metric: _chartMetric,
                onMetricChanged: (m) => setState(() => _chartMetric = m),
                dateRange: _dateRange,
                onDateRangeChanged: (r) => setState(() => _dateRange = r),
              ),
              loading: () => const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('Gagal memuat grafik: $err'),
            ),

            // 5. Unified Machine Media Section (Photos & Videos bound to the selected GymMachine)
            const SizedBox(height: 18),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: ExerciseMediaGallery(
                  exerciseId: effectiveExerciseId,
                  gymMachineId: effectiveMachineId,
                  machineTitle: machinesAsync.asData?.value
                      .where((m) => m.machine.id == effectiveMachineId)
                      .map(_formatMachineLabel)
                      .firstOrNull,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Gagal memuat gerakan: $err')),
    );
  }
}

/// Visual bottom sheet picker showing each registered [GymMachineWithDetails]
/// with its photo/video thumbnail preview, brand name, gym location, pinned notes,
/// and weight unit badge.
class _VisualMachineFilterPickerSheet extends StatelessWidget {
  const _VisualMachineFilterPickerSheet({
    required this.exerciseId,
    required this.machines,
    required this.selectedMachineId,
  });

  final String exerciseId;
  final List<GymMachineWithDetails> machines;
  final String? selectedMachineId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pilih Alat & Lokasi Gym',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                Card(
                  color: selectedMachineId == null
                      ? colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    onTap: () => Navigator.of(
                      context,
                    ).pop((selected: true, id: null)),
                    leading: MachineThumbnailAvatar(
                      exerciseId: exerciseId,
                      gymMachineId: null,
                      size: 52,
                    ),
                    title: const Text(
                      'Semua Alat / Global (Semua Gym)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Gabungkan histori dari seluruh alat & lokasi gym',
                    ),
                    trailing: selectedMachineId == null
                        ? const Icon(Icons.check_circle)
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                ...machines.map((item) {
                  final isSelected = item.machine.id == selectedMachineId;
                  final brand = item.machine.brandName ??
                      item.exercise.equipmentCategory.label;
                  final gymName =
                      item.gymLocation?.name ?? 'Global (Semua Gym)';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? colorScheme.primaryContainer : null,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(
                        context,
                      ).pop((selected: true, id: item.machine.id)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            MachineThumbnailAvatar(
                              exerciseId: exerciseId,
                              gymMachineId: item.machine.id,
                              size: 60,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    brand,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '📍 $gymName • ${item.machine.weightUnit.label}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  if (item.machine.pinnedNotes != null &&
                                      item.machine.pinnedNotes!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '📌 ${item.machine.pinnedNotes}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickExerciseSearchSheet extends StatefulWidget {
  const _QuickExerciseSearchSheet({required this.exercises});

  final List<Exercise> exercises;

  @override
  State<_QuickExerciseSearchSheet> createState() =>
      _QuickExerciseSearchSheetState();
}

class _QuickExerciseSearchSheetState extends State<_QuickExerciseSearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.exercises.where((e) {
      if (_query.trim().isEmpty) return true;
      return e.name.toLowerCase().contains(_query.trim().toLowerCase());
    }).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pilih Gerakan untuk Analitik',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Cari nama gerakan...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
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
                  onTap: () => Navigator.of(context).pop(ex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
