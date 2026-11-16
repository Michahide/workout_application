import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../../../core/sync/local_backup_service.dart';
import '../../../core/sync/sync_engine.dart';
import '../data/app_settings_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isBackupBusy = false;

  Future<void> _saveSettings(
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

  Future<void> _showCustomDurationDialog({
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

  Future<void> _showEndpointConfigSheet(SyncEngineState syncState) async {
    final urlCtrl = TextEditingController(text: syncState.apiBaseUrl);
    final tokenCtrl = TextEditingController(text: syncState.authToken);

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Konfigurasi Self-Hosted Cloud Sync',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'API Base URL',
                hintText: 'https://workout-sync.example.com',
                prefixIcon: Icon(Icons.cloud_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tokenCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Bearer Token / API Key (Opsional)',
                hintText: 'eyJhbGciOiJIUzI1NiIs...',
                prefixIcon: Icon(Icons.key_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.check),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Simpan Konfigurasi Server'),
              ),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      await ref.read(syncControllerProvider.notifier).updateEndpointConfig(
            apiBaseUrl: urlCtrl.text,
            authToken: tokenCtrl.text,
          );
    }

    urlCtrl.dispose();
    tokenCtrl.dispose();
  }

  Future<void> _handleExportBackup() async {
    setState(() => _isBackupBusy = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await ref.read(localBackupServiceProvider).exportFullBackupZip(db);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export backup gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackupBusy = false);
    }
  }

  Future<void> _handleRestoreBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore dari Backup (.zip)?'),
        content: const Text(
          'Data database lokal dan folder media (foto & video) saat ini akan ditimpa dengan isi file .zip yang Anda pilih. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Pilih File .zip & Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isBackupBusy = true);
    try {
      final restored = await ref
          .read(localBackupServiceProvider)
          .importFullBackupZip(ref);
      if (restored && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup .zip berhasil di-restore! Semua data telah diperbarui.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackupBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsStreamProvider);
    final syncState = ref.watch(syncControllerProvider);
    final pendingOutboxAsync = ref.watch(pendingOutboxCountStreamProvider);
    final pendingCount = pendingOutboxAsync.asData?.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Cloud Sync'),
      ),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
            children: [
              // 1. CLOUD SYNC STATUS CARD
              _CloudSyncStatusCard(
                syncState: syncState,
                pendingOutboxCount: pendingCount,
                onTapConfigure: () => _showEndpointConfigSheet(syncState),
                onTapSyncNow: () =>
                    ref.read(syncControllerProvider.notifier).triggerSyncNow(),
              ),
              const SizedBox(height: 16),

              // 2. LOCAL BACKUP & RESTORE CARD
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_zip_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Local Offline Backup & Restore (.zip)',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cadangkan seluruh database SQLite beserta seluruh foto & video latihan (.webp / .mp4) ke dalam 1 file .zip untuk disimpan atau dipindahkan ke HP lain secara offline.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed:
                                  _isBackupBusy ? null : _handleExportBackup,
                              icon: const Icon(Icons.upload_file_outlined),
                              label: const Text('Export Backup (.zip)'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed:
                                  _isBackupBusy ? null : _handleRestoreBackup,
                              icon: const Icon(
                                Icons.settings_backup_restore_rounded,
                              ),
                              label: const Text('Restore (.zip)'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. WARM-UP REST TIMER DEFAULTS CARD
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
                            settings,
                            largeMuscleWarmupRestSeconds: newVal,
                          ),
                          onTapCustom: () => _showCustomDurationDialog(
                            title: 'Warm-up Otot Besar (LARGE)',
                            initialSeconds:
                                settings.largeMuscleWarmupRestSeconds,
                            onSaved: (newVal) => _saveSettings(
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
                            settings,
                            smallMuscleWarmupRestSeconds: newVal,
                          ),
                          onTapCustom: () => _showCustomDurationDialog(
                            title: 'Warm-up Otot Kecil (SMALL)',
                            initialSeconds:
                                settings.smallMuscleWarmupRestSeconds,
                            onSaved: (newVal) => _saveSettings(
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
                            settings,
                            globalWarmupRestSeconds: newVal,
                          ),
                          onTapCustom: () => _showCustomDurationDialog(
                            title: 'Global Warm-up Rest',
                            initialSeconds: settings.globalWarmupRestSeconds,
                            onSaved: (newVal) => _saveSettings(
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

              // 4. WORKING SET REST TIMER CARD
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
                          settings,
                          defaultWorkingSetRestSeconds: newVal,
                        ),
                        onTapCustom: () => _showCustomDurationDialog(
                          title: 'Default Working Set Rest',
                          initialSeconds: settings.defaultWorkingSetRestSeconds,
                          onSaved: (newVal) => _saveSettings(
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

class _CloudSyncStatusCard extends StatelessWidget {
  const _CloudSyncStatusCard({
    required this.syncState,
    required this.pendingOutboxCount,
    required this.onTapConfigure,
    required this.onTapSyncNow,
  });

  final SyncEngineState syncState;
  final int pendingOutboxCount;
  final VoidCallback onTapConfigure;
  final VoidCallback onTapSyncNow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('d MMM yyyy, HH:mm:ss');

    final (statusLabel, badgeColor, badgeTextColor, icon) =
        switch (syncState.phase) {
      CloudSyncPhase.uploadingMedia => (
          'Syncing (Uploading Media...)',
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
          Icons.cloud_upload_outlined,
        ),
      CloudSyncPhase.pushingOutbox => (
          'Syncing (Pushing Outbox...)',
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
          Icons.sync_rounded,
        ),
      CloudSyncPhase.pullingDelta => (
          'Syncing (Pulling Delta...)',
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
          Icons.cloud_download_outlined,
        ),
      CloudSyncPhase.offline => (
          'Offline ($pendingOutboxCount items pending)',
          Colors.amber.shade800,
          Colors.white,
          Icons.cloud_off_rounded,
        ),
      CloudSyncPhase.error => (
          'Sync Error ($pendingOutboxCount pending)',
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
          Icons.error_outline_rounded,
        ),
      CloudSyncPhase.synced => (
          pendingOutboxCount == 0
              ? 'Synced'
              : 'Synced ($pendingOutboxCount new items pending)',
          Colors.green.shade700,
          Colors.white,
          Icons.cloud_done_rounded,
        ),
      CloudSyncPhase.idle => (
          syncState.isConfigured
              ? 'Ready ($pendingOutboxCount items pending)'
              : 'Offline-Only ($pendingOutboxCount items pending)',
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
          Icons.cloud_queue_rounded,
        ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cloud Sync Engine',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SyncInfoTile(
                    label: 'Pending Outbox',
                    value: '$pendingOutboxCount perubahan lokal',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SyncInfoTile(
                    label: 'Last Synced At',
                    value: syncState.lastSyncedAt != null
                        ? dateFmt.format(syncState.lastSyncedAt!.toLocal())
                        : 'Belum pernah',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            InkWell(
              onTap: onTapConfigure,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.dns_outlined, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        syncState.isConfigured
                            ? 'Server: ${syncState.apiBaseUrl}'
                            : 'Self-Hosted Backend URL belum dikonfigurasi (Ketuk untuk mengatur)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Icon(Icons.edit_outlined, size: 16),
                  ],
                ),
              ),
            ),

            if (syncState.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                syncState.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTapConfigure,
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Server & Token'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: syncState.isSyncing ? null : onTapSyncNow,
                    icon: syncState.isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_rounded, size: 18),
                    label: Text(
                      syncState.isSyncing ? 'Syncing...' : 'Sync Now',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncInfoTile extends StatelessWidget {
  const _SyncInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
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
