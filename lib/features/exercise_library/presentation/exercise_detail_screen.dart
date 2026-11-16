import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../../gym_locations/data/gym_location_repository.dart';
import '../../gym_locations/presentation/gym_locations_providers.dart';
import '../../gym_locations/presentation/gym_machine_form_sheet.dart';
import '../data/exercise_library_repository.dart';
import 'exercise_form_sheet.dart';
import 'exercise_library_providers.dart';
import 'exercise_media_gallery.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  Future<void> _openEditExerciseSheet(
    BuildContext context,
    Exercise exercise,
  ) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ExerciseFormSheet(existingExercise: exercise),
    );
  }

  Future<void> _openAddMachineSheet(
    BuildContext context, {
    GymMachine? existingMachine,
  }) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => GymMachineFormSheet(
        existingMachine: existingMachine,
        fixedExerciseId: exerciseId,
      ),
    );
  }

  Future<void> _confirmDeleteExercise(
    BuildContext context,
    WidgetRef ref,
    Exercise exercise,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Gerakan?'),
        content: Text('Hapus "${exercise.name}" secara soft-delete?'),
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
          .read(exerciseLibraryRepositoryProvider)
          .softDeleteExercise(exercise.id);
      if (context.mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseDetailStreamProvider(exerciseId));
    final machinesAsync = ref.watch(gymMachinesByExerciseProvider(exerciseId));

    return Scaffold(
      appBar: AppBar(
        title: Text(exerciseAsync.asData?.value?.name ?? 'Detail Gerakan'),
        actions: [
          if (exerciseAsync.asData?.value != null) ...[
            IconButton(
              tooltip: 'Edit Gerakan',
              onPressed: () => _openEditExerciseSheet(
                context,
                exerciseAsync.asData!.value!,
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
            if (exerciseAsync.asData!.value!.isCustom)
              IconButton(
                tooltip: 'Hapus Custom Exercise',
                onPressed: () => _confirmDeleteExercise(
                  context,
                  ref,
                  exerciseAsync.asData!.value!,
                ),
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ],
      ),
      body: exerciseAsync.when(
        data: (exercise) {
          if (exercise == null) {
            return const Center(child: Text('Gerakan tidak ditemukan.'));
          }

          final colorScheme = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              // Exercise Metadata Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (exercise.isCustom)
                            Chip(
                              label: const Text('Custom'),
                              backgroundColor: colorScheme.tertiaryContainer,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.accessibility_new_rounded,
                        label: 'Otot Utama',
                        value: exercise.primaryMuscleGroup.label,
                      ),
                      if (exercise.secondaryMuscleGroups.isNotEmpty)
                        _InfoRow(
                          icon: Icons.group_work_outlined,
                          label: 'Otot Sekunder',
                          value: exercise.secondaryMuscleGroups
                              .map((m) => m.label)
                              .join(', '),
                        ),
                      _InfoRow(
                        icon: Icons.handyman_outlined,
                        label: 'Kategori Alat',
                        value: exercise.equipmentCategory.label,
                      ),
                      _InfoRow(
                        icon: Icons.straighten_rounded,
                        label: 'Kategori Ukuran Otot',
                        value: exercise.muscleSizeCategory.label,
                      ),
                      _InfoRow(
                        icon: Icons.tune_rounded,
                        label: 'Tipe Pencatatan',
                        value:
                            '${exercise.exerciseType.label} — ${exercise.exerciseType.description}',
                      ),
                      if (exercise.defaultWorkingRestSeconds != null)
                        _InfoRow(
                          icon: Icons.timer_outlined,
                          label: 'Target Rest Working Set',
                          value: '${exercise.defaultWorkingRestSeconds} detik',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Media Gallery Section (4 Photos & 3 Videos with WebP thumbnails)
              ExerciseMediaGallery(exerciseId: exercise.id),
              const SizedBox(height: 24),

              // Linked Gym Machines Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Alat Terdaftar per Gym',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openAddMachineSheet(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Alat'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              machinesAsync.when(
                data: (machines) {
                  if (machines.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.precision_manufacturing_outlined,
                            size: 36,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada alat gym yang dihubungkan ke gerakan ini.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: machines.map((item) {
                      final machine = item.machine;
                      final gymName =
                          item.gymLocation?.name ?? 'Global (Semua Gym)';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.storefront_outlined),
                          title: Text(
                            machine.brandName != null
                                ? '$gymName • ${machine.brandName}'
                                : gymName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: machine.pinnedNotes != null
                              ? Text('📌 ${machine.pinnedNotes}')
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  machine.weightUnit.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _openAddMachineSheet(
                                  context,
                                  existingMachine: machine,
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                              ),
                              IconButton(
                                onPressed: () => ref
                                    .read(gymLocationRepositoryProvider)
                                    .softDeleteGymMachine(machine.id),
                                icon:
                                    const Icon(Icons.delete_outline, size: 18),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Gagal memuat daftar alat: $e'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Gagal memuat detail gerakan: $err')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
