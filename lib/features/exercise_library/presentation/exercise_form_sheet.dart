import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../../../core/database/tables.dart';
import '../data/exercise_library_repository.dart';

/// Modal bottom sheet form to create or edit a Custom Exercise.
/// Automatically infers `muscleSizeCategory` (`LARGE` vs `SMALL`) from
/// `primaryMuscleGroup`, while allowing manual override by the user.
class ExerciseFormSheet extends ConsumerStatefulWidget {
  const ExerciseFormSheet({super.key, this.existingExercise});

  final Exercise? existingExercise;

  @override
  ConsumerState<ExerciseFormSheet> createState() => _ExerciseFormSheetState();
}

class _ExerciseFormSheetState extends ConsumerState<ExerciseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _defaultRestController;

  late EquipmentCategory _equipmentCategory;
  late MuscleGroup _primaryMuscleGroup;
  late Set<MuscleGroup> _secondaryMuscleGroups;
  late MuscleSizeCategory _muscleSizeCategory;
  bool _hasManualSizeOverride = false;
  late ExerciseType _exerciseType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingExercise;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _defaultRestController = TextEditingController(
      text: existing?.defaultWorkingRestSeconds?.toString() ?? '',
    );
    _equipmentCategory =
        existing?.equipmentCategory ?? EquipmentCategory.barbell;
    _primaryMuscleGroup = existing?.primaryMuscleGroup ?? MuscleGroup.chest;
    _secondaryMuscleGroups = {
      ...(existing?.secondaryMuscleGroups ?? const <MuscleGroup>[]),
    };
    _muscleSizeCategory =
        existing?.muscleSizeCategory ?? _primaryMuscleGroup.defaultSizeCategory;
    _hasManualSizeOverride = existing != null &&
        existing.muscleSizeCategory !=
            existing.primaryMuscleGroup.defaultSizeCategory;
    _exerciseType = existing?.exerciseType ?? ExerciseType.weight_reps;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _defaultRestController.dispose();
    super.dispose();
  }

  void _onPrimaryMuscleChanged(MuscleGroup? newGroup) {
    if (newGroup == null) return;
    setState(() {
      _primaryMuscleGroup = newGroup;
      _secondaryMuscleGroups.remove(newGroup);
      if (!_hasManualSizeOverride) {
        _muscleSizeCategory = newGroup.defaultSizeCategory;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final restText = _defaultRestController.text.trim();
    final parsedRest = restText.isEmpty ? null : int.tryParse(restText);

    try {
      final repo = ref.read(exerciseLibraryRepositoryProvider);
      if (widget.existingExercise == null) {
        await repo.createCustomExercise(
          name: _nameController.text,
          equipmentCategory: _equipmentCategory,
          primaryMuscleGroup: _primaryMuscleGroup,
          secondaryMuscleGroups: _secondaryMuscleGroups.toList(growable: false),
          muscleSizeCategoryOverride: _muscleSizeCategory,
          exerciseType: _exerciseType,
          defaultWorkingRestSeconds: parsedRest,
        );
      } else {
        await repo.updateExercise(
          id: widget.existingExercise!.id,
          name: _nameController.text,
          equipmentCategory: _equipmentCategory,
          primaryMuscleGroup: _primaryMuscleGroup,
          secondaryMuscleGroups: _secondaryMuscleGroups.toList(growable: false),
          muscleSizeCategoryOverride: _muscleSizeCategory,
          exerciseType: _exerciseType,
          defaultWorkingRestSeconds: parsedRest,
        );
      }

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
    final isEditing = widget.existingExercise != null;
    final autoSize = _primaryMuscleGroup.defaultSizeCategory;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Gerakan' : 'Tambah Custom Exercise',
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                autofocus: !isEditing,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama Gerakan *',
                  hintText: 'Contoh: Pendulum Squat / Bayesian Cable Curl',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Nama gerakan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<EquipmentCategory>(
                initialValue: _equipmentCategory,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Kategori Alat (Equipment)',
                  prefixIcon: Icon(Icons.handyman_outlined),
                  border: OutlineInputBorder(),
                ),
                items: EquipmentCategory.values
                    .map(
                      (eq) => DropdownMenuItem(
                        value: eq,
                        child: Text(eq.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _equipmentCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<MuscleGroup>(
                initialValue: _primaryMuscleGroup,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Otot Utama (Primary Muscle)',
                  prefixIcon: Icon(Icons.accessibility_new_rounded),
                  border: OutlineInputBorder(),
                ),
                items: MuscleGroup.values
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          '${m.label} (${m.defaultSizeCategory.shortLabel})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _onPrimaryMuscleChanged,
              ),
              const SizedBox(height: 16),

              // Muscle Size Category with Auto-Inference + Manual Override
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Kategori Ukuran Otot (Rest Timer Warm-up)',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (_hasManualSizeOverride)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _hasManualSizeOverride = false;
                          _muscleSizeCategory = autoSize;
                        });
                      },
                      child: const Text('Reset Otomatis'),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              SegmentedButton<MuscleSizeCategory>(
                segments: MuscleSizeCategory.values
                    .map(
                      (size) => ButtonSegment<MuscleSizeCategory>(
                        value: size,
                        label: Text(size.label),
                      ),
                    )
                    .toList(),
                selected: {_muscleSizeCategory},
                onSelectionChanged: (selected) {
                  final chosen = selected.first;
                  setState(() {
                    _muscleSizeCategory = chosen;
                    _hasManualSizeOverride = chosen != autoSize;
                  });
                },
              ),
              const SizedBox(height: 4),
              Text(
                _hasManualSizeOverride
                    ? 'Manual override aktif (default untuk ${_primaryMuscleGroup.label}: ${autoSize.shortLabel})'
                    : 'Otomatis mengikuti otot utama (${_primaryMuscleGroup.label} → ${autoSize.shortLabel})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),

              Text(
                'Otot Sekunder (Opsional)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: MuscleGroup.values
                    .where((m) => m != _primaryMuscleGroup)
                    .map((muscle) {
                  final isSelected = _secondaryMuscleGroups.contains(muscle);
                  return FilterChip(
                    label: Text(muscle.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _secondaryMuscleGroups.add(muscle);
                        } else {
                          _secondaryMuscleGroups.remove(muscle);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<ExerciseType>(
                initialValue: _exerciseType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Tipe Pencatatan (Exercise Type)',
                  prefixIcon: Icon(Icons.tune_rounded),
                  border: OutlineInputBorder(),
                ),
                items: ExerciseType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _exerciseType = value);
                  }
                },
              ),
              const SizedBox(height: 6),
              Text(
                _exerciseType.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _defaultRestController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Istirahat Working Set (Detik - Opsional)',
                  hintText: 'Kosongkan untuk mengikuti default aplikasi (180 dtk)',
                  prefixIcon: Icon(Icons.timer_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(isEditing ? 'Simpan Perubahan' : 'Simpan Gerakan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
