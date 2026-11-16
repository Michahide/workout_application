import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../data/app_settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _saveSettings(
    WidgetRef ref,
    AppSetting current, {
    bool? useSplitWarmupRest,
    int? largeMuscleWarmupRestSeconds,
    int? smallMuscleWarmupRestSeconds,
    int? globalWarmupRestSeconds,
    int? defaultWorkingSetRestSeconds,
  }) async {
    await ref.read(appSettingsRepositoryProvider).updateSettings(
          useSplitWarmupRest: useSplitWarmupRest ?? current.useSplitWarmupRest,
          largeMuscleWarmupRestSeconds: largeMuscleWarmupRestSeconds ??
              current.largeMuscleWarmupRestSeconds,
          smallMuscleWarmupRestSeconds: smallMuscleWarmupRestSeconds ??
              current.smallMuscleWarmupRestSeconds,
          globalWarmupRestSeconds:
              globalWarmupRestSeconds ?? current.globalWarmupRestSeconds,
          defaultWorkingSetRestSeconds: defaultWorkingSetRestSeconds ??
              current.defaultWorkingSetRestSeconds,
        );
  }

  Future<void> _showCustomDurationDialog(
    BuildContext context, {
    required String title,
    required int initialSeconds,
    required ValueChanged<int> onSaved,
  }) async {
    final minutesCtrl = TextEditingController(
      text: (initialSeconds ~/ 60).toString(),
    );
    final secondsCtrl = TextEditingController(
      text: (initialSeconds % 60).toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: minutesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Menit',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(':', style: TextStyle(fontSize: 22)),
            ),
            Expanded(
              child: TextField(
                controller: secondsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Detik',
                  border: OutlineInputBorder(),
                ),
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
              final mins = int.tryParse(minutesCtrl.text.trim()) ?? 0;
              final secs = int.tryParse(secondsCtrl.text.trim()) ?? 0;
              final total = (mins * 60 + secs).clamp(10, 900);
              Navigator.of(ctx).pop(total);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    minutesCtrl.dispose();
    secondsCtrl.dispose();

    if (result != null) {
      onSaved(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Rest Timer'),
      ),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Konfigurasi Istirahat Warm-up Set',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Pisahkan Rest Warm-up Otot Besar vs Kecil',
                        ),
                        subtitle: const Text(
                          'Jika aktif, otot besar (Chest/Back/Legs) dan otot kecil (Shoulders/Arms/Abs) memiliki durasi rest warm-up berbeda.',
                        ),
                        value: settings.useSplitWarmupRest,
                        onChanged: (value) => _saveSettings(
                          ref,
                          settings,
                          useSplitWarmupRest: value,
                        ),
                      ),
                      const Divider(),
                      if (settings.useSplitWarmupRest) ...[
                        _DurationSettingTile(
                          title: 'Warm-up Otot Besar (LARGE)',
                          subtitle:
                              'Chest, Lats, Upper Back, Quads, Hamstrings, Glutes',
                          seconds: settings.largeMuscleWarmupRestSeconds,
                          onChanged: (newVal) => _saveSettings(
                            ref,
                            settings,
                            largeMuscleWarmupRestSeconds: newVal,
                          ),
                          onTapCustom: () => _showCustomDurationDialog(
                            context,
                            title: 'Warm-up Otot Besar (LARGE)',
                            initialSeconds:
                                settings.largeMuscleWarmupRestSeconds,
                            onSaved: (newVal) => _saveSettings(
                              ref,
                              settings,
                              largeMuscleWarmupRestSeconds: newVal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DurationSettingTile(
                          title: 'Warm-up Otot Kecil (SMALL)',
                          subtitle:
                              'Delts, Biceps, Triceps, Calves, Abs, Forearms, Traps',
                          seconds: settings.smallMuscleWarmupRestSeconds,
                          onChanged: (newVal) => _saveSettings(
                            ref,
                            settings,
                            smallMuscleWarmupRestSeconds: newVal,
                          ),
                          onTapCustom: () => _showCustomDurationDialog(
                            context,
                            title: 'Warm-up Otot Kecil (SMALL)',
                            initialSeconds:
                                settings.smallMuscleWarmupRestSeconds,
                            onSaved: (newVal) => _saveSettings(
                              ref,
                              settings,
                              smallMuscleWarmupRestSeconds: newVal,
                            ),
                          ),
                        ),
                      ] else ...[
                        _DurationSettingTile(
                          title: 'Global Warm-up Rest',
                          subtitle: 'Berlaku untuk seluruh gerakan pemanasan',
                          seconds: settings.globalWarmupRestSeconds,
                          onChanged: (newVal) => _saveSettings(
                            ref,
                            settings,
                            globalWarmupRestSeconds: newVal,
                          ),
                          onTapCustom: () => _showCustomDurationDialog(
                            context,
                            title: 'Global Warm-up Rest',
                            initialSeconds: settings.globalWarmupRestSeconds,
                            onSaved: (newVal) => _saveSettings(
                              ref,
                              settings,
                              globalWarmupRestSeconds: newVal,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Konfigurasi Istirahat Working Set',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _DurationSettingTile(
                        title: 'Default Working Set Rest',
                        subtitle:
                            'Digunakan pada Normal, Drop Set, dan Failure Set jika gerakan/plan tidak menentukan target khusus',
                        seconds: settings.defaultWorkingSetRestSeconds,
                        onChanged: (newVal) => _saveSettings(
                          ref,
                          settings,
                          defaultWorkingSetRestSeconds: newVal,
                        ),
                        onTapCustom: () => _showCustomDurationDialog(
                          context,
                          title: 'Default Working Set Rest',
                          initialSeconds: settings.defaultWorkingSetRestSeconds,
                          onSaved: (newVal) => _saveSettings(
                            ref,
                            settings,
                            defaultWorkingSetRestSeconds: newVal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat pengaturan: $err')),
      ),
    );
  }
}

class _DurationSettingTile extends StatelessWidget {
  const _DurationSettingTile({
    required this.title,
    required this.subtitle,
    required this.seconds,
    required this.onChanged,
    required this.onTapCustom,
  });

  final String title;
  final String subtitle;
  final int seconds;
  final ValueChanged<int> onChanged;
  final VoidCallback onTapCustom;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            OutlinedButton(
              onPressed: seconds > 15 ? () => onChanged(seconds - 15) : null,
              child: const Text('-15s'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: onTapCustom,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${formatRestDuration(seconds)} (${seconds}s)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Ketuk untuk ubah manual (mm:ss)',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: seconds < 900 ? () => onChanged(seconds + 15) : null,
              child: const Text('+15s'),
            ),
          ],
        ),
      ],
    );
  }
}
