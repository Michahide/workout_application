import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/domain_labels.dart';
import '../../../../core/database/tables.dart';
import '../../../active_workout/data/active_workout_repository.dart';
import '../../data/analytics_repository.dart';
import '../analytics_providers.dart';

/// Sub-tab 2: Displays the chronological list of completed workout sessions
/// (`completedAt IS NOT NULL`), including session duration, gym name, working sets,
/// working volume, and PR count. Tapping opens the full session detail & editor sheet.
class WorkoutHistoryTab extends ConsumerWidget {
  const WorkoutHistoryTab({super.key});

  Future<void> _openSessionDetailSheet(
    BuildContext context,
    CompletedWorkoutSessionSummary item,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CompletedSessionDetailSheet(summary: item),
    );
  }

  Future<void> _confirmDeleteSession(
    BuildContext context,
    WidgetRef ref,
    CompletedWorkoutSessionSummary item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Riwayat Sesi?'),
        content: const Text(
          'Sesi latihan ini beserta seluruh catatan set-nya akan dihapus secara soft-delete.',
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
          .read(analyticsRepositoryProvider)
          .softDeleteCompletedSession(item.session.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(completedWorkoutSessionsProvider);
    final dateFmt = DateFormat('EEE, d MMM yyyy • HH:mm');
    final colorScheme = Theme.of(context).colorScheme;

    return historyAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 56,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada riwayat sesi latihan yang selesai.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Selesaikan sesi latihan di tab Workout untuk melihat log histori dan grafik progres Anda.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: sessions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = sessions[index];
            final title = item.planName ?? 'Empty Workout';
            final completedDate =
                (item.session.completedAt ?? item.session.startedAt).toLocal();

            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openSessionDetailSheet(context, item),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateFmt.format(completedDate),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (item.newPRsCount > 0)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🏆 ${item.newPRsCount} PR',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Hapus Sesi',
                            onPressed: () =>
                                _confirmDeleteSession(context, ref, item),
                            icon: const Icon(Icons.delete_outline, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (item.gymName != null)
                            _HistoryMetricChip(
                              icon: Icons.storefront_outlined,
                              label: item.gymName!,
                            ),
                          _HistoryMetricChip(
                            icon: Icons.timer_outlined,
                            label: formatCompactDuration(item.durationSeconds),
                          ),
                          _HistoryMetricChip(
                            icon: Icons.check_circle_outline,
                            label: '${item.totalWorkingSets} Working Sets',
                          ),
                          _HistoryMetricChip(
                            icon: Icons.fitness_center_outlined,
                            label:
                                'Vol: ${item.totalWorkingVolume.round()}',
                          ),
                        ],
                      ),
                      if (item.session.sessionNotes != null &&
                          item.session.sessionNotes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '📝 ${item.session.sessionNotes!}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Gagal memuat riwayat: $err')),
    );
  }
}

class _HistoryMetricChip extends StatelessWidget {
  const _HistoryMetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Full detail sheet for a completed workout session, allowing the user to
/// inspect every exercise and set (including `targetRestSeconds` vs `actualRestSeconds`)
/// and edit set values if there was a typo.
class _CompletedSessionDetailSheet extends ConsumerWidget {
  const _CompletedSessionDetailSheet({required this.summary});

  final CompletedWorkoutSessionSummary summary;

  Future<void> _editHistoricalSetDialog(
    BuildContext context,
    WidgetRef ref,
    WorkoutSet workoutSet,
    WeightUnit weightUnit,
  ) async {
    final weightCtrl = TextEditingController(
      text: workoutSet.weight?.toString() ?? '',
    );
    final repsCtrl = TextEditingController(
      text: workoutSet.reps?.toString() ?? '',
    );
    final rpeCtrl = TextEditingController(
      text: workoutSet.rpe?.toString() ?? '',
    );
    final actualRestCtrl = TextEditingController(
      text: workoutSet.actualRestSeconds?.toString() ?? '',
    );
    var selectedAssistance = workoutSet.assistanceType;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit Set #${workoutSet.setNumber}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Beban (${weightUnit.label})',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: repsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Repetisi (Reps)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: rpeCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'RPE (6.0 - 10.0)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: actualRestCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Actual Rest (Detik)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<AssistanceType>(
                  initialValue: selectedAssistance,
                  decoration: const InputDecoration(
                    labelText: 'Status Spotter',
                    border: OutlineInputBorder(),
                  ),
                  items: AssistanceType.values
                      .map(
                        (a) => DropdownMenuItem(
                          value: a,
                          child: Text(a.label),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedAssistance = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      await ref.read(activeWorkoutRepositoryProvider).updateSet(
            setId: workoutSet.id,
            weight: Value(double.tryParse(weightCtrl.text.trim())),
            reps: Value(int.tryParse(repsCtrl.text.trim())),
            rpe: Value(double.tryParse(rpeCtrl.text.trim())),
            actualRestSeconds: Value(int.tryParse(actualRestCtrl.text.trim())),
            assistanceType: selectedAssistance,
          );
    }

    weightCtrl.dispose();
    repsCtrl.dispose();
    rpeCtrl.dispose();
    actualRestCtrl.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFmt = DateFormat('EEEE, d MMMM yyyy • HH:mm');
    final completedDate =
        (summary.session.completedAt ?? summary.session.startedAt).toLocal();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.planName ?? 'Empty Workout',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          '${dateFmt.format(completedDate)} • ${summary.gymName ?? "Gym"}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: summary.exercises.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final exDetail = summary.exercises[index];
                  final unit = exDetail.machine?.weightUnit ?? WeightUnit.KG;

                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exDetail.exercise.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            exDetail.machine != null
                                ? 'Alat: ${exDetail.machine!.brandName ?? exDetail.exercise.equipmentCategory.label} (${unit.label})'
                                : 'Alat: ${exDetail.exercise.equipmentCategory.label}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Divider(height: 16),
                          ...exDetail.sets.map((s) {
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              onTap: () => _editHistoricalSetDialog(
                                context,
                                ref,
                                s,
                                unit,
                              ),
                              leading: CircleAvatar(
                                radius: 14,
                                child: Text(
                                  s.setType == SetType.normal
                                      ? '${s.setNumber}'
                                      : s.setType.shortBadge,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${s.weight ?? 0} ${unit.label} × ${s.reps ?? 0} reps'
                                '${s.rpe != null ? " @ RPE ${s.rpe}" : ""}'
                                ' (${s.assistanceType.label})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Actual Rest: ${s.actualRestSeconds != null ? formatCompactDuration(s.actualRestSeconds!) : "—"} '
                                '/ Target: ${s.targetRestSeconds != null ? formatCompactDuration(s.targetRestSeconds!) : "—"}',
                              ),
                              trailing: const Icon(
                                Icons.edit_outlined,
                                size: 16,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
