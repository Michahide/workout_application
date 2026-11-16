import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../gym_locations/data/gym_location_repository.dart';
import '../../gym_locations/presentation/gym_locations_providers.dart';
import '../data/active_workout_repository.dart';

/// Modal bottom sheet that prompts the user to select their current Gym Location
/// (or quick-create a new gym) before starting a Workout Session.
class StartWorkoutGymSheet extends ConsumerStatefulWidget {
  const StartWorkoutGymSheet({
    super.key,
    this.workoutPlanId,
    this.workoutPlanName,
  });

  final String? workoutPlanId;
  final String? workoutPlanName;

  /// Helper to show the sheet and return `true` if a workout session was started.
  static Future<bool> show(
    BuildContext context, {
    String? workoutPlanId,
    String? workoutPlanName,
  }) async {
    final started = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => StartWorkoutGymSheet(
        workoutPlanId: workoutPlanId,
        workoutPlanName: workoutPlanName,
      ),
    );
    return started == true;
  }

  @override
  ConsumerState<StartWorkoutGymSheet> createState() =>
      _StartWorkoutGymSheetState();
}

class _StartWorkoutGymSheetState extends ConsumerState<StartWorkoutGymSheet> {
  String? _selectedGymId;
  bool _isQuickAddingGym = false;
  final _quickGymNameCtrl = TextEditingController();
  final _quickGymAddressCtrl = TextEditingController();
  bool _isStarting = false;

  @override
  void dispose() {
    _quickGymNameCtrl.dispose();
    _quickGymAddressCtrl.dispose();
    super.dispose();
  }

  Future<void> _quickCreateGym() async {
    final name = _quickGymNameCtrl.text.trim();
    if (name.isEmpty) return;

    final gymId = await ref
        .read(gymLocationRepositoryProvider)
        .createGymLocation(
          name: name,
          address: _quickGymAddressCtrl.text,
        );

    if (mounted) {
      setState(() {
        _selectedGymId = gymId;
        _isQuickAddingGym = false;
        _quickGymNameCtrl.clear();
        _quickGymAddressCtrl.clear();
      });
    }
  }

  Future<void> _startSession(List<GymLocation> gyms) async {
    final targetGymId =
        _selectedGymId ?? (gyms.isNotEmpty ? gyms.first.id : null);
    if (targetGymId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih atau tambahkan lokasi gym terlebih dahulu.'),
        ),
      );
      return;
    }

    setState(() => _isStarting = true);
    try {
      await ref.read(activeWorkoutRepositoryProvider).startWorkoutSession(
            gymLocationId: targetGymId,
            workoutPlanId: widget.workoutPlanId,
          );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymsAsync = ref.watch(gymLocationsListProvider);
    final title = widget.workoutPlanName != null
        ? 'Mulai "${widget.workoutPlanName}"'
        : 'Mulai Empty Workout';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: gymsAsync.when(
        data: (gyms) {
          final currentSelection =
              _selectedGymId ?? (gyms.isNotEmpty ? gyms.first.id : null);

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih lokasi gym Anda saat ini agar aplikasi otomatis mencocokkan merk mesin dan histori beban terakhir di gym tersebut.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),

                if (gyms.isEmpty && !_isQuickAddingGym)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Belum ada lokasi gym terdaftar. Tambahkan gym pertama Anda:',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: () =>
                              setState(() => _isQuickAddingGym = true),
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: const Text('Tambah Lokasi Gym Cepat'),
                        ),
                      ],
                    ),
                  )
                else ...[
                  ...gyms.map((gym) {
                    final isSelected = gym.id == currentSelection;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        onTap: () => setState(() => _selectedGymId = gym.id),
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(
                          gym.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            gym.address != null ? Text(gym.address!) : null,
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(
                        () => _isQuickAddingGym = !_isQuickAddingGym,
                      ),
                      icon: Icon(
                        _isQuickAddingGym ? Icons.expand_less : Icons.add,
                      ),
                      label: const Text('Tambah Gym Baru Cepat'),
                    ),
                  ),
                ],

                if (_isQuickAddingGym) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _quickGymNameCtrl,
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: 'Nama Gym Baru *',
                              hintText: 'Contoh: Gym Cabang Kuningan',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _quickGymAddressCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Alamat / Catatan (Opsional)',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.tonalIcon(
                            onPressed: _quickCreateGym,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Simpan & Pilih Gym Ini'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _isStarting || currentSelection == null
                      ? null
                      : () => _startSession(gyms),
                  icon: _isStarting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Mulai Latihan Sekarang'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Text('Gagal memuat daftar gym: $err'),
      ),
    );
  }
}
