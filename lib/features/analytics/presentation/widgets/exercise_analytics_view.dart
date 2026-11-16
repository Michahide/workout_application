import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/domain_labels.dart';
import '../../../exercise_library/presentation/exercise_library_providers.dart';
import '../../../gym_locations/data/gym_location_repository.dart';
import '../../../gym_locations/presentation/gym_locations_providers.dart';
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

  String _formatMachineLabel(GymMachineWithDetails item) {
    final gymName = item.gymLocation?.name ?? 'Global';
    final brand = item.machine.brandName ?? item.exercise.equipmentCategory.label;
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

            // 2. Machine at Gym Filter Dropdown + Solo vs Include Assisted Toggle
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    machinesAsync.when(
                      data: (machines) {
                        final validMachineId = machines.any(
                          (m) => m.machine.id == effectiveMachineId,
                        )
                            ? effectiveMachineId
                            : null;

                        return DropdownButtonFormField<String?>(
                          initialValue: validMachineId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filter Spesifik Alat & Lokasi Gym',
                            prefixIcon: Icon(
                              Icons.precision_manufacturing_outlined,
                            ),
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Semua Alat / Global (Semua Gym)'),
                            ),
                            ...machines.map(
                              (m) => DropdownMenuItem<String?>(
                                value: m.machine.id,
                                child: Text(
                                  _formatMachineLabel(m),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedExerciseId = effectiveExerciseId;
                              _selectedGymMachineId = val;
                              _hasResolvedDefaultMachine = true;
                            });
                          },
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Gagal memuat mesin: $e'),
                    ),
                    const SizedBox(height: 6),
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
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Gagal memuat gerakan: $err')),
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
