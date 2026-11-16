import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../../../core/database/tables.dart';
import '../data/gym_location_repository.dart';
import 'gym_locations_providers.dart';
import 'gym_machine_form_sheet.dart';

class GymLocationDetailScreen extends ConsumerWidget {
  const GymLocationDetailScreen({super.key, required this.gymId});

  final String gymId;

  Future<void> _openMachineForm(
    BuildContext context, {
    GymMachine? existingMachine,
  }) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => GymMachineFormSheet(
        existingMachine: existingMachine,
        fixedGymLocationId: gymId,
      ),
    );
  }

  Future<void> _confirmDeleteMachine(
    BuildContext context,
    WidgetRef ref,
    GymMachineWithDetails item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Alat Gym?'),
        content: Text(
          'Hapus "${item.machine.brandName ?? item.exercise.name}" dari gym ini?',
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
          .read(gymLocationRepositoryProvider)
          .softDeleteGymMachine(item.machine.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymAsync = ref.watch(gymLocationDetailProvider(gymId));
    final machinesAsync = ref.watch(gymMachinesByGymProvider(gymId));

    return Scaffold(
      appBar: AppBar(
        title: Text(gymAsync.asData?.value?.name ?? 'Detail Gym'),
      ),
      body: gymAsync.when(
        data: (gym) {
          if (gym == null) {
            return const Center(child: Text('Lokasi gym tidak ditemukan.'));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Card(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.storefront_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  gym.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          if (gym.address != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.place_outlined, size: 16),
                                const SizedBox(width: 6),
                                Expanded(child: Text(gym.address!)),
                              ],
                            ),
                          ],
                          if (gym.notes != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.notes_outlined, size: 16),
                                const SizedBox(width: 6),
                                Expanded(child: Text(gym.notes!)),
                              ],
                            ),
                          ],
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
                        'Daftar Alat & Mesin Terdaftar',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () => _openMachineForm(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah Alat'),
                      ),
                    ],
                  ),
                ),
              ),
              machinesAsync.when(
                data: (machines) {
                  if (machines.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.precision_manufacturing_outlined,
                                size: 52,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Belum ada alat yang didaftarkan di gym ini.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.tonalIcon(
                                onPressed: () => _openMachineForm(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Daftarkan Alat Pertama'),
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
                      itemCount: machines.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = machines[index];
                        return _GymMachineCard(
                          item: item,
                          onTapExercise: () =>
                              context.push('/exercises/${item.exercise.id}'),
                          onEdit: () => _openMachineForm(
                            context,
                            existingMachine: item.machine,
                          ),
                          onDelete: () =>
                              _confirmDeleteMachine(context, ref, item),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(child: Text('Gagal memuat alat: $err')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat detail gym: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openMachineForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alat'),
      ),
    );
  }
}

class _GymMachineCard extends StatelessWidget {
  const _GymMachineCard({
    required this.item,
    required this.onTapExercise,
    required this.onEdit,
    required this.onDelete,
  });

  final GymMachineWithDetails item;
  final VoidCallback onTapExercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final machine = item.machine;
    final exercise = item.exercise;
    final colorScheme = Theme.of(context).colorScheme;

    final badgeColor = switch (machine.weightUnit) {
      WeightUnit.KG => colorScheme.primaryContainer,
      WeightUnit.LBS => colorScheme.tertiaryContainer,
      WeightUnit.STACK_NUMBER => colorScheme.secondaryContainer,
    };

    final badgeTextColor = switch (machine.weightUnit) {
      WeightUnit.KG => colorScheme.onPrimaryContainer,
      WeightUnit.LBS => colorScheme.onTertiaryContainer,
      WeightUnit.STACK_NUMBER => colorScheme.onSecondaryContainer,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTapExercise,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          machine.brandName != null
                              ? '${machine.brandName} • ${exercise.primaryMuscleGroup.label}'
                              : '${exercise.equipmentCategory.label} • ${exercise.primaryMuscleGroup.label}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      machine.weightUnit.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: badgeTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Edit Alat',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Hapus Alat',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
              ),
              if (machine.pinnedNotes != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.push_pin_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          machine.pinnedNotes!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
