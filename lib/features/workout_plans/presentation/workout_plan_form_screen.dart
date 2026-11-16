import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../../exercise_library/presentation/exercise_library_providers.dart';
import '../data/workout_plan_repository.dart';

/// Full-screen modal for creating or editing a [WorkoutPlan], ordering its
/// exercises via drag-and-drop, grouping Supersets, and configuring target sets/reps/rest.
class WorkoutPlanFormScreen extends ConsumerStatefulWidget {
  const WorkoutPlanFormScreen({super.key, this.existingPlan});

  final WorkoutPlanWithExercises? existingPlan;

  @override
  ConsumerState<WorkoutPlanFormScreen> createState() =>
      _WorkoutPlanFormScreenState();
}

class _WorkoutPlanFormScreenState extends ConsumerState<WorkoutPlanFormScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;

  late List<WorkoutPlanExerciseDraft> _drafts;
  final Set<int> _selectedIndicesForSuperset = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingPlan;
    _nameController = TextEditingController(text: existing?.plan.name ?? '');
    _notesController = TextEditingController(text: existing?.plan.notes ?? '');
    _drafts = existing?.exercises
            .map(
              (item) => WorkoutPlanExerciseDraft(
                id: item.planExercise.id,
                exerciseId: item.planExercise.exerciseId,
                defaultGymMachineId: item.planExercise.defaultGymMachineId,
                supersetGroupId: item.planExercise.supersetGroupId,
                targetSets: item.planExercise.targetSets,
                targetReps: item.planExercise.targetReps,
                targetRestSeconds: item.planExercise.targetRestSeconds,
              ),
            )
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickExercisesToAdd(List<Exercise> allExercises) async {
    final chosenExercise = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ExercisePickerModal(allExercises: allExercises),
    );

    if (chosenExercise != null) {
      setState(() {
        _drafts.add(
          WorkoutPlanExerciseDraft(
            exerciseId: chosenExercise.id,
            targetSets: 3,
            targetReps: 10,
            targetRestSeconds: chosenExercise.defaultWorkingRestSeconds,
          ),
        );
      });
    }
  }

  void _groupSelectedAsSuperset() {
    if (_selectedIndicesForSuperset.length < 2) return;
    final newGroupId = 'ss_${_uuid.v4().substring(0, 8)}';
    setState(() {
      for (final idx in _selectedIndicesForSuperset) {
        if (idx >= 0 && idx < _drafts.length) {
          _drafts[idx] = _drafts[idx].copyWith(
            supersetGroupId: () => newGroupId,
          );
        }
      }
      _selectedIndicesForSuperset.clear();
    });
  }

  void _ungroupSupersetAt(int index) {
    setState(() {
      _drafts[index] = _drafts[index].copyWith(supersetGroupId: () => null);
      _selectedIndicesForSuperset.remove(index);
    });
  }

  Future<void> _editDraftTargets(
    int index,
    WorkoutPlanExerciseDraft draft,
    String exerciseName,
  ) async {
    final setsCtrl = TextEditingController(text: draft.targetSets.toString());
    final repsCtrl = TextEditingController(
      text: draft.targetReps?.toString() ?? '',
    );
    final restCtrl = TextEditingController(
      text: draft.targetRestSeconds?.toString() ?? '',
    );

    final updated = await showDialog<WorkoutPlanExerciseDraft>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Target: $exerciseName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: setsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Jumlah Set *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Repetisi (Opsional)',
                hintText: 'Contoh: 10',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: restCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Custom Target Rest (Detik - Opsional)',
                hintText: 'Kosongkan untuk pakai default Settings',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final parsedSets = (int.tryParse(setsCtrl.text.trim()) ?? 3)
                  .clamp(1, 20);
              final repsText = repsCtrl.text.trim();
              final restText = restCtrl.text.trim();
              Navigator.of(ctx).pop(
                draft.copyWith(
                  targetSets: parsedSets,
                  targetReps: () =>
                      repsText.isEmpty ? null : int.tryParse(repsText),
                  targetRestSeconds: () =>
                      restText.isEmpty ? null : int.tryParse(restText),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    setsCtrl.dispose();
    repsCtrl.dispose();
    restCtrl.dispose();

    if (updated != null) {
      setState(() => _drafts[index] = updated);
    }
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_drafts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal 1 gerakan ke dalam Workout Plan.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(workoutPlanRepositoryProvider).saveWorkoutPlan(
            existingPlanId: widget.existingPlan?.plan.id,
            name: _nameController.text,
            notes: _notesController.text,
            exerciseDrafts: _drafts,
          );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(allExercisesStreamProvider);
    final isEditing = widget.existingPlan != null;
    final badges = computeSupersetBadges(
      _drafts.map((d) => d.supersetGroupId).toList(growable: false),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Workout Plan' : 'Buat Workout Plan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _savePlan,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Simpan Plan'),
            ),
          ),
        ],
      ),
      body: exercisesAsync.when(
        data: (allExercises) {
          final exerciseMap = {for (final e in allExercises) e.id: e};

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Workout Plan *',
                          hintText: 'Contoh: Push Day A / Upper Body Hypertrophy',
                          prefixIcon: Icon(Icons.event_note_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            (val == null || val.trim().isEmpty)
                                ? 'Nama plan wajib diisi'
                                : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Rutinitas (Opsional)',
                          hintText: 'Contoh: Fokus progressive overload incline press',
                          prefixIcon: Icon(Icons.notes_outlined),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Superset Action Bar & Add Exercise Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Urutan Gerakan (${_drafts.length})',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_selectedIndicesForSuperset.length >= 2)
                        FilledButton.tonalIcon(
                          onPressed: _groupSelectedAsSuperset,
                          icon: const Icon(Icons.link_rounded, size: 18),
                          label: Text(
                            'Gabung Superset (${_selectedIndicesForSuperset.length})',
                          ),
                        )
                      else
                        TextButton.icon(
                          onPressed: () => _pickExercisesToAdd(allExercises),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Gerakan'),
                        ),
                    ],
                  ),
                ),
                if (_drafts.length >= 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tips: Centang ≥ 2 gerakan untuk menggabungkan Superset, atau tahan & geser ikon garis untuk mengubah urutan.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                const SizedBox(height: 6),

                Expanded(
                  child: _drafts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.playlist_add_outlined,
                                size: 52,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Belum ada gerakan di dalam plan ini.',
                              ),
                              const SizedBox(height: 12),
                              FilledButton.tonalIcon(
                                onPressed: () =>
                                    _pickExercisesToAdd(allExercises),
                                icon: const Icon(Icons.add),
                                label: const Text('Pilih Gerakan'),
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                          itemCount: _drafts.length,
                          onReorderItem: (oldIndex, newIndex) {
                            setState(() {
                              final moved = _drafts.removeAt(oldIndex);
                              _drafts.insert(newIndex, moved);
                              _selectedIndicesForSuperset.clear();
                            });
                          },
                          itemBuilder: (context, index) {
                            final draft = _drafts[index];
                            final exercise = exerciseMap[draft.exerciseId];
                            final exerciseName =
                                exercise?.name ?? 'Gerakan Tidak Dikenal';
                            final supersetBadge = badges[index];
                            final isChecked =
                                _selectedIndicesForSuperset.contains(index);
                            final colorScheme = Theme.of(context).colorScheme;

                            return Card(
                              key: ValueKey(
                                draft.id ?? '${draft.exerciseId}_$index',
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isChecked,
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedIndicesForSuperset.add(
                                              index,
                                            );
                                          } else {
                                            _selectedIndicesForSuperset.remove(
                                              index,
                                            );
                                          }
                                        });
                                      },
                                    ),
                                    if (supersetBadge != null)
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.tertiaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          supersetBadge,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onTertiaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _editDraftTargets(
                                          index,
                                          draft,
                                          exerciseName,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              exerciseName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                Text(
                                                  '${draft.targetSets} Set × ${draft.targetReps ?? "-"} Reps',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall,
                                                ),
                                                Text(
                                                  draft.targetRestSeconds !=
                                                          null
                                                      ? '• Rest ${formatCompactDuration(draft.targetRestSeconds!)}'
                                                      : '• Rest Default',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (draft.supersetGroupId != null)
                                      IconButton(
                                        tooltip: 'Lepas Superset',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () =>
                                            _ungroupSupersetAt(index),
                                        icon: const Icon(
                                          Icons.link_off_rounded,
                                          size: 18,
                                        ),
                                      ),
                                    IconButton(
                                      tooltip: 'Ubah Target Set/Reps',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _editDraftTargets(
                                        index,
                                        draft,
                                        exerciseName,
                                      ),
                                      icon: const Icon(
                                        Icons.tune_rounded,
                                        size: 18,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Hapus dari Plan',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        setState(() {
                                          _drafts.removeAt(index);
                                          _selectedIndicesForSuperset.clear();
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                      ),
                                    ),
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: Icon(Icons.drag_handle_rounded),
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
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat gerakan: $err')),
      ),
      floatingActionButton: exercisesAsync.asData != null
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _pickExercisesToAdd(exercisesAsync.asData!.value),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Gerakan'),
            )
          : null,
    );
  }
}

class _ExercisePickerModal extends StatefulWidget {
  const _ExercisePickerModal({required this.allExercises});

  final List<Exercise> allExercises;

  @override
  State<_ExercisePickerModal> createState() => _ExercisePickerModalState();
}

class _ExercisePickerModalState extends State<_ExercisePickerModal> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.allExercises.where((e) {
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
                  'Pilih Gerakan Latihan',
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
            onChanged: (val) => setState(() => _query = val),
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
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${ex.primaryMuscleGroup.label} • ${ex.equipmentCategory.label}',
                  ),
                  trailing: const Icon(Icons.add_circle_outline),
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
