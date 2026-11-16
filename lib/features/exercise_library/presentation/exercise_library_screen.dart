import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../../../core/database/tables.dart';
import 'exercise_form_sheet.dart';
import 'exercise_library_providers.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateExerciseSheet() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ExerciseFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(exerciseFilterControllerProvider);
    final filterNotifier = ref.read(exerciseFilterControllerProvider.notifier);
    final exercisesAsync = ref.watch(filteredExercisesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          if (filter.hasActiveFilters)
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                filterNotifier.clearFilters();
              },
              icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: const Text('Reset'),
            ),
          IconButton(
            tooltip: 'Tambah Custom Exercise',
            onPressed: _openCreateExerciseSheet,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: filterNotifier.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari nama gerakan (misal: Bench, Squat, Lat)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filter.searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          filterNotifier.setSearchQuery('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          // Muscle Group Filter Chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Semua Otot'),
                    selected: filter.primaryMuscleGroup == null,
                    onSelected: (_) => filterNotifier.setMuscleGroup(null),
                  ),
                ),
                ...MuscleGroup.values.map(
                  (muscle) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(muscle.label),
                      selected: filter.primaryMuscleGroup == muscle,
                      onSelected: (selected) => filterNotifier.setMuscleGroup(
                        selected ? muscle : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Equipment Category Filter Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Semua Alat'),
                    selected: filter.equipmentCategory == null,
                    onSelected: (_) =>
                        filterNotifier.setEquipmentCategory(null),
                  ),
                ),
                ...EquipmentCategory.values.map(
                  (eq) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(eq.label),
                      selected: filter.equipmentCategory == eq,
                      onSelected: (selected) =>
                          filterNotifier.setEquipmentCategory(
                        selected ? eq : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 16),

          // Exercise List
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 56,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tidak ada gerakan yang sesuai filter.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: _openCreateExerciseSheet,
                            icon: const Icon(Icons.add),
                            label: const Text('Buat Custom Exercise'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: exercises.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _ExerciseListTile(
                      exercise: exercise,
                      onTap: () => context.push('/exercises/${exercise.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Gagal memuat gerakan: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateExerciseSheet,
        icon: const Icon(Icons.add),
        label: const Text('Custom Exercise'),
      ),
    );
  }
}

class _ExerciseListTile extends StatelessWidget {
  const _ExerciseListTile({
    required this.exercise,
    required this.onTap,
  });

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLarge = exercise.muscleSizeCategory == MuscleSizeCategory.LARGE;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (exercise.isCustom)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'CUSTOM',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _TagChip(
                          label: exercise.primaryMuscleGroup.label,
                          backgroundColor: colorScheme.primaryContainer,
                          textColor: colorScheme.onPrimaryContainer,
                        ),
                        _TagChip(
                          label: exercise.equipmentCategory.label,
                          backgroundColor: colorScheme.secondaryContainer,
                          textColor: colorScheme.onSecondaryContainer,
                        ),
                        _TagChip(
                          label: exercise.muscleSizeCategory.shortLabel,
                          backgroundColor: isLarge
                              ? colorScheme.errorContainer
                              : colorScheme.surfaceContainerHighest,
                          textColor: isLarge
                              ? colorScheme.onErrorContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                        _TagChip(
                          label: exercise.exerciseType.label,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          textColor: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    if (exercise.secondaryMuscleGroups.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Sekunder: ${exercise.secondaryMuscleGroups.map((m) => m.label).join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
