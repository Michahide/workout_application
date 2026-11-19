import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../../../core/database/tables.dart';
import '../../exercise_library/presentation/exercise_library_providers.dart';
import '../data/gym_location_repository.dart';
import 'gym_locations_providers.dart';

/// Modal bottom sheet for creating or editing a [GymMachine].
/// Supports pre-filling either [fixedGymLocationId] (from Gym Detail Screen)
/// or [fixedExerciseId] (from Exercise Detail Screen).
class GymMachineFormSheet extends ConsumerStatefulWidget {
  const GymMachineFormSheet({
    super.key,
    this.existingMachine,
    this.fixedGymLocationId,
    this.fixedExerciseId,
  });

  final GymMachine? existingMachine;
  final String? fixedGymLocationId;
  final String? fixedExerciseId;

  @override
  ConsumerState<GymMachineFormSheet> createState() =>
      _GymMachineFormSheetState();
}

class _GymMachineFormSheetState extends ConsumerState<GymMachineFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _brandController;
  late final TextEditingController _pinnedNotesController;

  String? _selectedGymLocationId;
  String? _selectedExerciseId;
  late WeightUnit _selectedWeightUnit;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingMachine;
    _brandController = TextEditingController(text: existing?.brandName ?? '');
    _pinnedNotesController = TextEditingController(
      text: existing?.pinnedNotes ?? '',
    );
    _selectedGymLocationId =
        existing?.gymLocationId ?? widget.fixedGymLocationId;
    _selectedExerciseId = existing?.exerciseId ?? widget.fixedExerciseId;
    _selectedWeightUnit = existing?.weightUnit ?? WeightUnit.KG;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _pinnedNotesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExerciseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gerakan (exercise) terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(gymLocationRepositoryProvider);
      if (widget.existingMachine == null) {
        await repo.createGymMachine(
          gymLocationId: _selectedGymLocationId,
          exerciseId: _selectedExerciseId!,
          brandName: _brandController.text,
          weightUnit: _selectedWeightUnit,
          pinnedNotes: _pinnedNotesController.text,
        );
      } else {
        await repo.updateGymMachine(
          id: widget.existingMachine!.id,
          gymLocationId: _selectedGymLocationId,
          exerciseId: _selectedExerciseId!,
          brandName: _brandController.text,
          weightUnit: _selectedWeightUnit,
          pinnedNotes: _pinnedNotesController.text,
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
    final exercisesAsync = ref.watch(allExercisesStreamProvider);
    final gymsAsync = ref.watch(gymLocationsListProvider);
    final isEditing = widget.existingMachine != null;

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
                      isEditing ? 'Edit Alat Gym' : 'Tambah Alat Gym',
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

              // Gym Location Selector (if not fixed to a single gym)
              if (widget.fixedGymLocationId == null) ...[
                gymsAsync.when(
                  data: (gyms) => DropdownButtonFormField<String?>(
                    initialValue: _selectedGymLocationId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi Gym',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Global (Semua Gym)'),
                      ),
                      ...gyms.map(
                        (g) => DropdownMenuItem<String?>(
                          value: g.id,
                          child: Text(g.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedGymLocationId = value);
                    },
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Gagal memuat gym: $e'),
                ),
                const SizedBox(height: 16),
              ],

              // Exercise Selector (if not fixed to a single exercise)
              if (widget.fixedExerciseId == null) ...[
                exercisesAsync.when(
                  data: (exercises) => DropdownButtonFormField<String>(
                    initialValue: exercises.any((e) => e.id == _selectedExerciseId)
                        ? _selectedExerciseId
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Gerakan (Exercise) *',
                      prefixIcon: Icon(Icons.fitness_center),
                      border: OutlineInputBorder(),
                    ),
                    items: exercises
                        .map(
                          (ex) => DropdownMenuItem<String>(
                            value: ex.id,
                            child: Text(
                              '${ex.name} (${ex.primaryMuscleGroup.label})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    validator: (val) =>
                        val == null ? 'Pilih gerakan latihan' : null,
                    onChanged: (value) {
                      setState(() => _selectedExerciseId = value);
                    },
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Gagal memuat gerakan: $e'),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _brandController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Merk & Identitas Mesin *',
                  hintText:
                      'Contoh: Hoist, Technogym Mesin #1 (Pojok), Technogym Mesin #2',
                  helperText:
                      'Beri penanda unik jika ada >1 mesin bermerk sama karena rasio katrol/beban bisa berbeda.',
                  helperMaxLines: 2,
                  prefixIcon: Icon(Icons.precision_manufacturing_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Masukkan merk atau nama pembeda mesin'
                    : null,
              ),
              const SizedBox(height: 16),

              Text(
                'Satuan Berat Alat',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<WeightUnit>(
                segments: WeightUnit.values
                    .map(
                      (unit) => ButtonSegment<WeightUnit>(
                        value: unit,
                        label: Text(unit.label),
                        icon: Icon(switch (unit) {
                          WeightUnit.KG => Icons.scale_outlined,
                          WeightUnit.LBS => Icons.balance_outlined,
                          WeightUnit.STACK_NUMBER =>
                            Icons.format_list_numbered_rounded,
                        }),
                      ),
                    )
                    .toList(),
                selected: {_selectedWeightUnit},
                onSelectionChanged: (selection) {
                  setState(() => _selectedWeightUnit = selection.first);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _pinnedNotesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Pinned Notes / Setting Alat',
                  hintText: 'Contoh: Kursi level 4, sandaran dada lubang ke-3',
                  prefixIcon: Icon(Icons.push_pin_outlined),
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
                  child: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Alat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
