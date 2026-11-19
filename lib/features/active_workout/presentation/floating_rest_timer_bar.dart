import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/domain_labels.dart';
import '../domain/rest_timer_controller.dart';

/// Floating bottom bar displaying either:
/// 1. The active timestamp-based Rest Timer countdown (with overtime counter,
///    elapsed actual rest indicator, `-15s`, `+15s`, and `Skip` controls), OR
/// 2. A Superset transition banner prompting the lifter to perform the next
///    movement in the superset round before starting the main rest timer.
class FloatingRestTimerBar extends ConsumerWidget {
  const FloatingRestTimerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerControllerProvider);
    final controller = ref.read(restTimerControllerProvider.notifier);

    if (!timerState.isRunning && timerState.nextSupersetBanner == null) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    // Superset Transition Guidance Banner
    if (!timerState.isRunning && timerState.nextSupersetBanner != null) {
      return Material(
        elevation: 6,
        color: colorScheme.tertiaryContainer,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  color: colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timerState.nextSupersetBanner!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Transisi: ${formatRestDuration(timerState.elapsedSeconds)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onTertiaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: controller.skipTimer,
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isOvertime = timerState.isOvertime;
    final remaining = timerState.remainingSeconds;
    final elapsed = timerState.elapsedSeconds;

    final barBgColor = isOvertime
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final barTextColor = isOvertime
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Material(
      elevation: 8,
      color: barBgColor,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: timerState.progress,
              minHeight: 4,
              backgroundColor: barBgColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    isOvertime
                        ? Icons.notification_important_rounded
                        : Icons.timer_rounded,
                    color: barTextColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOvertime
                              ? 'OVERTIME ${formatRestDuration(remaining)}'
                              : 'Rest ${formatRestDuration(remaining)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: barTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Elapsed: ${formatRestDuration(elapsed)} / Target: ${formatRestDuration(timerState.targetRestSeconds)}'
                          '${timerState.exerciseName != null ? " • ${timerState.exerciseName!}" : ""}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: barTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: '-15 detik',
                    onPressed: () => controller.adjustTargetRest(-15),
                    icon: Text(
                      '-15s',
                      style: TextStyle(
                        color: barTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: '+15 detik',
                    onPressed: () => controller.adjustTargetRest(15),
                    icon: Text(
                      '+15s',
                      style: TextStyle(
                        color: barTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: controller.skipTimer,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
