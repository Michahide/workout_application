import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/domain_labels.dart';
import '../../../../core/database/tables.dart';
import '../../data/analytics_repository.dart';
import '../analytics_providers.dart';

/// Interactive `fl_chart` LineChart supporting 4 progression metrics:
/// 1. Estimated 1RM (Epley)
/// 2. Best Set Volume
/// 3. Total Session Volume
/// 4. Actual Rest Time Trend
///
/// Features:
/// - Rich dual-context touch tooltip (`LineTouchData`) showing Date, Gym & Machine,
///   Best Set Weight × Reps, Estimated 1RM, RPE, Actual Rest, and Solo/Assisted status.
/// - Distinct hollow orange dot styling (`FlDotCirclePainter`) for data points
///   where `wasAssisted == true`.
class ExerciseProgressionChart extends StatelessWidget {
  const ExerciseProgressionChart({
    super.key,
    required this.points,
    required this.metric,
    required this.onMetricChanged,
    required this.dateRange,
    required this.onDateRangeChanged,
  });

  final List<SessionExerciseProgressionPoint> points;
  final AnalyticsChartMetric metric;
  final ValueChanged<AnalyticsChartMetric> onMetricChanged;
  final AnalyticsDateRange dateRange;
  final ValueChanged<AnalyticsDateRange> onDateRangeChanged;

  double? _extractValue(SessionExerciseProgressionPoint p) {
    return switch (metric) {
      AnalyticsChartMetric.estimated1RM =>
        p.bestEstimated1RM ?? p.bestSetWeight,
      AnalyticsChartMetric.bestSetVolume => p.bestSetVolume,
      AnalyticsChartMetric.totalSessionVolume => p.totalWorkingVolume,
      AnalyticsChartMetric.actualRestSeconds => p.avgActualRestSeconds,
    };
  }

  String _formatNum(double val) {
    return val == val.roundToDouble()
        ? val.toInt().toString()
        : val.toStringAsFixed(1);
  }

  String _unitSuffix(WeightUnit unit) => switch (unit) {
        WeightUnit.KG => 'kg',
        WeightUnit.LBS => 'lbs',
        WeightUnit.STACK_NUMBER => 'stk',
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Filter points that have a valid numeric value for the selected metric
    final validEntries = <({int index, SessionExerciseProgressionPoint point, double y})>[];
    for (var i = 0; i < points.length; i++) {
      final y = _extractValue(points[i]);
      if (y != null && y > 0) {
        validEntries.add((
          index: validEntries.length,
          point: points[i],
          y: y,
        ));
      }
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Metric Selector Segmented Button
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<AnalyticsChartMetric>(
                showSelectedIcon: false,
                segments: AnalyticsChartMetric.values
                    .map(
                      (m) => ButtonSegment<AnalyticsChartMetric>(
                        value: m,
                        label: Text(
                          m.shortLabel,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                    .toList(),
                selected: {metric},
                onSelectionChanged: (sel) => onMetricChanged(sel.first),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle & Date Range Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    metric.fullTitle,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Wrap(
                  spacing: 4,
                  children: AnalyticsDateRange.values.map((range) {
                    final selected = range == dateRange;
                    return ChoiceChip(
                      label: Text(
                        range.shortLabel,
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                      selected: selected,
                      onSelected: (_) => onDateRangeChanged(range),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (validEntries.isEmpty)
              SizedBox(
                height: 210,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.show_chart_rounded,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada data sesi untuk metrik & rentang waktu ini.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 230,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 8),
                  child: _buildLineChart(context, validEntries),
                ),
              ),
              const SizedBox(height: 10),
              // Legend for Solo vs Assisted dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Solo / Spotted (Unassisted)',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange.shade800,
                        width: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Assisted by Spotter',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(
    BuildContext context,
    List<({int index, SessionExerciseProgressionPoint point, double y})> entries,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final spots = entries
        .map((e) => FlSpot(e.index.toDouble(), e.y))
        .toList(growable: false);

    final yValues = entries.map((e) => e.y).toList(growable: false);
    final rawMinY = yValues.reduce(math.min);
    final rawMaxY = yValues.reduce(math.max);
    final ySpan = (rawMaxY - rawMinY).abs();
    final padding = ySpan == 0 ? (rawMaxY * 0.15).clamp(2.0, 50.0) : ySpan * 0.2;
    final minY = math.max(0.0, rawMinY - padding);
    final maxY = rawMaxY + padding;

    final shortDateFmt = DateFormat('d/M');
    final fullDateFmt = DateFormat('d MMM yyyy');

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: math.max(0, entries.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant),
            left: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (val, meta) {
                if (val == meta.min || val == meta.max) {
                  return const SizedBox.shrink();
                }
                final label =
                    metric == AnalyticsChartMetric.actualRestSeconds
                        ? '${val.round()}s'
                        : _formatNum(val);
                return Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                      ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: entries.length > 6
                  ? (entries.length / 5).ceilToDouble()
                  : 1,
              getTitlesWidget: (val, meta) {
                final idx = val.round();
                if (idx < 0 || idx >= entries.length) {
                  return const SizedBox.shrink();
                }
                final dt = entries[idx].point.sessionDate.toLocal();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    shortDateFmt.format(dt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            maxContentWidth: 250,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => Colors.grey.shade900.withValues(alpha: 0.94),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((barSpot) {
                final idx = barSpot.x.round();
                if (idx < 0 || idx >= entries.length) return null;
                final p = entries[idx].point;
                final unitStr = _unitSuffix(p.weightUnit);
                final dateStr = fullDateFmt.format(p.sessionDate.toLocal());
                final locParts = [
                  if (p.gymName != null) p.gymName!,
                  if (p.machineBrand != null) p.machineBrand!,
                ];
                final locLine =
                    locParts.isNotEmpty ? ' (${locParts.join(" - ")})' : '';

                final bestSetLine = (p.bestSetWeight != null &&
                        p.bestSetReps != null)
                    ? 'Best Set: ${_formatNum(p.bestSetWeight!)} $unitStr × ${p.bestSetReps} reps'
                        '${p.bestEstimated1RM != null ? " (1RM: ${_formatNum(p.bestEstimated1RM!)} $unitStr)" : ""}'
                    : 'Vol: ${_formatNum(p.bestSetVolume)}';

                final rpePart =
                    p.bestSetRpe != null ? 'RPE: ${_formatNum(p.bestSetRpe!)}' : 'RPE: —';
                final restSec =
                    p.bestSetActualRestSeconds ?? p.avgActualRestSeconds?.round();
                final restPart = restSec != null
                    ? 'Actual Rest: ${formatCompactDuration(restSec)}'
                    : 'Rest: —';

                final statusText = p.wasAssisted
                    ? '⚠️ Status: Assisted by Spotter'
                    : 'Status: ${p.bestSetAssistanceType.label}';

                return LineTooltipItem(
                  '$dateStr$locLine\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  children: [
                    TextSpan(
                      text: '$bestSetLine\n',
                      style: const TextStyle(
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    TextSpan(
                      text: '$rpePart | $restPart\n',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10.5,
                      ),
                    ),
                    TextSpan(
                      text: statusText,
                      style: TextStyle(
                        color: p.wasAssisted
                            ? Colors.amberAccent
                            : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            preventCurveOverShooting: true,
            barWidth: 3,
            color: colorScheme.primary,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withValues(alpha: 0.14),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isAssisted = index >= 0 &&
                    index < entries.length &&
                    entries[index].point.wasAssisted;
                if (isAssisted) {
                  // Distinct hollow orange circle for Assisted sets
                  return FlDotCirclePainter(
                    radius: 5.5,
                    color: Colors.white,
                    strokeWidth: 2.8,
                    strokeColor: Colors.orange.shade800,
                  );
                }
                return FlDotCirclePainter(
                  radius: 4.2,
                  color: colorScheme.primary,
                  strokeWidth: 1.5,
                  strokeColor: colorScheme.surface,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
