import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../../analytics/presentation/widgets/exercise_analytics_view.dart';
import '../../gym_locations/data/gym_location_repository.dart';
import '../../gym_locations/presentation/gym_locations_providers.dart';
import '../../gym_locations/presentation/gym_machine_form_sheet.dart';
import '../../gym_locations/presentation/gym_machine_profile_card.dart';
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
              tooltip: 'Lihat Progress & PR',
              onPressed: () => ExerciseAnalyticsSheet.show(
                context,
                exerciseId: exerciseId,
              ),
              icon: const Icon(Icons.insights_rounded),
            ),
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
              // 1. Exercise Metadata Summary Card
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

              // 2. Unified Gym Machines Section (Merk + Foto/Video + 1RM + Working Set Progress)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Alat & Mesin (Merk, Media & 1RM)',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Tiap mesin menyimpan foto/video, catatan kursi, beban working set, dan 1RM secara terpisah.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => _openAddMachineSheet(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Alat'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                            'Belum ada mesin spesifik (misal Hoist / Technogym #1) yang didaftarkan untuk gerakan ini.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () => _openAddMachineSheet(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Daftarkan Alat & Foto Pertama'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: machines.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GymMachineProfileCard(
                          item: item,
                          showExerciseTitle: false,
                          showGymLocationName: true,
                          onEdit: () => _openAddMachineSheet(
                            context,
                            existingMachine: item.machine,
                          ),
                          onDelete: () => ref
                              .read(gymLocationRepositoryProvider)
                              .softDeleteGymMachine(item.machine.id),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Gagal memuat daftar alat: $e'),
              ),

              const SizedBox(height: 12),
              // Optional General Exercise Media Fallback (for Bodyweight/Free-Weight without specific machine)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Media Umum Gerakan (Tanpa Mesin Spesifik)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                subtitle: Text(
                  'Gunakan jika gerakan tidak terikat pada merk mesin tertentu (misal Bodyweight).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: ExerciseMediaGallery(
                      exerciseId: exercise.id,
                      gymMachineId: null,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Gagal memuat detail gerakan: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddMachineSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alat / Merk'),
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
