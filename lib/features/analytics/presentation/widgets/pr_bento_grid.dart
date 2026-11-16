import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/domain_labels.dart';
import '../../../../core/database/tables.dart';
import '../../data/analytics_repository.dart';

/// 2x2 Bento Grid displaying the 4 core Personal Records for an Exercise/Machine:
/// 1. Best Estimated 1RM (Epley)
/// 2. Heaviest Weight Lifted
/// 3. Best Single Set Volume
/// 4. Best Session Volume
class PRBentoGrid extends StatelessWidget {
  const PRBentoGrid({super.key, required this.summary});

  final ExercisePRSummary summary;

  String _formatNum(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  String _unitSuffix(WeightUnit unit) => switch (unit) {
        WeightUnit.KG => 'kg',
        WeightUnit.LBS => 'lbs',
        WeightUnit.STACK_NUMBER => 'stk',
      };

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d MMM yyyy');
    final e1rm = summary.bestEstimated1RM;
    final heaviest = summary.heaviestWeight;
    final bestSetVol = summary.bestSingleSetVolume;
    final bestSessVol = summary.bestSessionVolume;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary.hasMixedWeightUnits)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade700),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade800,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Perhatian: Filter "Semua Alat/Gym" aktif dan riwayat memiliki satuan berbeda '
                    '(${summary.distinctWeightUnits.map((u) => u.label).join(" vs ")}). '
                    'Pilih mesin spesifik untuk perbandingan akurat.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),

        if (summary.restOverloadInsight != null &&
            summary.restOverloadInsight!.restDeltaSeconds != 0)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: summary.restOverloadInsight!.isRestProgressiveOverload
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  summary.restOverloadInsight!.isRestProgressiveOverload
                      ? Icons.trending_up_rounded
                      : Icons.timer_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    summary.restOverloadInsight!.summary,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),

        Row(
          children: [
            Expanded(
              child: _BentoPRCard(
                icon: Icons.emoji_events_rounded,
                title: 'Best Est. 1RM',
                headline: e1rm != null
                    ? '${_formatNum(e1rm.value)} ${_unitSuffix(e1rm.weightUnit)}'
                    : '—',
                detail: e1rm != null
                    ? '${_formatNum(e1rm.weight ?? 0)} ${_unitSuffix(e1rm.weightUnit)} × ${e1rm.reps ?? 0}'
                        '${e1rm.rpe != null ? " @ RPE ${_formatNum(e1rm.rpe!)}" : ""}'
                    : 'Belum ada data',
                subDetail: e1rm != null
                    ? '${dateFmt.format(e1rm.achievedAt.toLocal())}'
                        '${e1rm.actualRestSeconds != null ? " • Rest ${formatCompactDuration(e1rm.actualRestSeconds!)}" : ""}'
                    : null,
                badgeText: e1rm?.isHighRepEstimate == true
                    ? 'High Rep (>12)'
                    : (e1rm?.assistanceType == AssistanceType.assisted
                        ? 'Assisted'
                        : null),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BentoPRCard(
                icon: Icons.fitness_center_rounded,
                title: summary.exercise.exerciseType ==
                        ExerciseType.assisted_bodyweight
                    ? 'Least Assistance'
                    : 'Heaviest Weight',
                headline: heaviest != null
                    ? '${_formatNum(heaviest.value)} ${_unitSuffix(heaviest.weightUnit)}'
                    : '—',
                detail: heaviest != null
                    ? '${heaviest.reps ?? 1} reps'
                        '${heaviest.rpe != null ? " @ RPE ${_formatNum(heaviest.rpe!)}" : ""}'
                    : 'Belum ada data',
                subDetail: heaviest != null
                    ? dateFmt.format(heaviest.achievedAt.toLocal())
                    : null,
                badgeText: heaviest?.assistanceType == AssistanceType.assisted
                    ? 'Assisted'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _BentoPRCard(
                icon: Icons.bolt_rounded,
                title: 'Best Set Volume',
                headline: bestSetVol != null
                    ? '${_formatNum(bestSetVol.value)} ${_unitSuffix(bestSetVol.weightUnit)}'
                    : '—',
                detail: bestSetVol != null &&
                        bestSetVol.weight != null &&
                        bestSetVol.reps != null
                    ? '${_formatNum(bestSetVol.weight!)} ${_unitSuffix(bestSetVol.weightUnit)} × ${bestSetVol.reps}'
                    : (bestSetVol != null ? 'Skor terbaik' : 'Belum ada data'),
                subDetail: bestSetVol != null
                    ? '${dateFmt.format(bestSetVol.achievedAt.toLocal())}'
                        '${bestSetVol.actualRestSeconds != null ? " • Rest ${formatCompactDuration(bestSetVol.actualRestSeconds!)}" : ""}'
                    : null,
                badgeText:
                    bestSetVol?.assistanceType == AssistanceType.assisted
                        ? 'Assisted'
                        : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BentoPRCard(
                icon: Icons.stacked_bar_chart_rounded,
                title: 'Best Session Vol',
                headline: bestSessVol != null
                    ? '${_formatNum(bestSessVol.value)} ${_unitSuffix(bestSessVol.weightUnit)}'
                    : '—',
                detail: bestSessVol?.gymName ??
                    (bestSessVol != null ? 'Total Working Sets' : 'Belum ada data'),
                subDetail: bestSessVol != null
                    ? dateFmt.format(bestSessVol.achievedAt.toLocal())
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoPRCard extends StatelessWidget {
  const _BentoPRCard({
    required this.icon,
    required this.title,
    required this.headline,
    required this.detail,
    this.subDetail,
    this.badgeText,
  });

  final IconData icon;
  final String title;
  final String headline;
  final String detail;
  final String? subDetail;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              headline,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (subDetail != null) ...[
              const SizedBox(height: 2),
              Text(
                subDetail!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
