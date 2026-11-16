import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../data/gym_location_repository.dart';
import 'gym_locations_providers.dart';

class GymLocationsScreen extends ConsumerWidget {
  const GymLocationsScreen({super.key});

  Future<void> _showGymFormSheet(
    BuildContext context, {
    GymLocation? existingGym,
  }) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _GymLocationFormSheet(existingGym: existingGym),
    );
  }

  Future<void> _confirmDeleteGym(
    BuildContext context,
    WidgetRef ref,
    GymLocation gym,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Lokasi Gym?'),
        content: Text(
          'Lokasi "${gym.name}" beserta daftar alatnya akan dihapus secara soft-delete.',
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
          .softDeleteGymLocation(gym.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymsAsync = ref.watch(gymLocationsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Gym'),
        actions: [
          IconButton(
            tooltip: 'Tambah Gym',
            onPressed: () => _showGymFormSheet(context),
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
        ],
      ),
      body: gymsAsync.when(
        data: (gyms) {
          if (gyms.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fitness_center_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada lokasi gym terdaftar',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan tempat gym langganan Anda untuk mencatat merk mesin, satuan berat (KG / LBS / Stack #), dan setting kursi.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _showGymFormSheet(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Gym Pertama'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: gyms.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final gym = gyms[index];
              final machinesAsync = ref.watch(gymMachinesByGymProvider(gym.id));
              final machineCount = machinesAsync.asData?.value.length ?? 0;

              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/gyms/${gym.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.storefront_rounded,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gym.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (gym.address != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.place_outlined,
                                      size: 15,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        gym.address!,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (gym.notes != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  gym.notes!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$machineCount alat terdaftar',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showGymFormSheet(context, existingGym: gym);
                            } else if (value == 'delete') {
                              _confirmDeleteGym(context, ref, gym);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit_outlined),
                                title: Text('Edit Gym'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete_outline),
                                title: Text('Hapus Gym'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat gym: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGymFormSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Gym'),
      ),
    );
  }
}

class _GymLocationFormSheet extends ConsumerStatefulWidget {
  const _GymLocationFormSheet({this.existingGym});

  final GymLocation? existingGym;

  @override
  ConsumerState<_GymLocationFormSheet> createState() =>
      _GymLocationFormSheetState();
}

class _GymLocationFormSheetState extends ConsumerState<_GymLocationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingGym?.name ?? '',
    );
    _addressController = TextEditingController(
      text: widget.existingGym?.address ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingGym?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(gymLocationRepositoryProvider);
      if (widget.existingGym == null) {
        await repo.createGymLocation(
          name: _nameController.text,
          address: _addressController.text,
          notes: _notesController.text,
        );
      } else {
        await repo.updateGymLocation(
          id: widget.existingGym!.id,
          name: _nameController.text,
          address: _addressController.text,
          notes: _notesController.text,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingGym != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing ? 'Edit Lokasi Gym' : 'Tambah Lokasi Gym',
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
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nama Gym *',
                hintText: 'Contoh: FTL Gym Senayan / Gym Dekat Rumah',
                prefixIcon: Icon(Icons.storefront_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Nama gym wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Alamat / Cabang (Opsional)',
                prefixIcon: Icon(Icons.place_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan Gym (Opsional)',
                hintText: 'Contoh: Dumbell lengkap s/d 50kg, parkir basement',
                prefixIcon: Icon(Icons.notes_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.check),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(isEditing ? 'Simpan Perubahan' : 'Simpan Gym'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
