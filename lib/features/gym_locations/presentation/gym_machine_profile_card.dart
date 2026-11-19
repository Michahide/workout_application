import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/domain_labels.dart';
import '../../../core/database/tables.dart';
import '../../active_workout/data/active_workout_repository.dart';
import '../../analytics/data/analytics_repository.dart';
import '../../analytics/presentation/analytics_providers.dart';
import '../../analytics/presentation/widgets/exercise_analytics_view.dart';
import '../../exercise_library/presentation/exercise_library_providers.dart';
import '../../exercise_library/presentation/exercise_media_gallery.dart';
import '../data/gym_location_repository.dart';

/// Unified card that binds together a specific physical machine ([GymMachine]):
/// 1. Exercise Name + Machine Brand/Identifier (e.g., "Hoist", "Technogym #1") + Gym Location + Weight Unit (`KG`/`LBS`/`STACK #`) + Pinned Notes
/// 2. Machine-specific 1RM & Last Working Set performance
/// 3. Machine-specific Photo & Video thumbnails + gallery launcher (`gymMachineId`)
/// 4. Machine-specific Progress & PR Chart launcher (`gymMachineId`)
class GymMachineProfileCard extends ConsumerWidget {
  const GymMachineProfileCard({
    super.key,
    required this.item,
    this.showExerciseTitle = true,
    this.showGymLocationName = true,
    this.onTapHeader,
    required this.onEdit,
    required this.onDelete,
  });

  final GymMachineWithDetails item;
  final bool showExerciseTitle;
  final bool showGymLocationName;
  final VoidCallback? onTapHeader;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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

  Future<void> _openMachineMediaSheet(
    BuildContext context,
    String machineTitle,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        maxChildSize: 0.94,
        minChildSize: 0.5,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.exercise.name,
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Alat: $machineTitle (${item.machine.weightUnit.label})',
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                color: Theme.of(ctx).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 20),
              ExerciseMediaGallery(
                exerciseId: item.exercise.id,
                gymMachineId: item.machine.id,
                machineTitle: machineTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machine = item.machine;
    final exercise = item.exercise;
    final gymName = item.gymLocation?.name ?? 'Global (Semua Gym)';
    final brandLabel =
        (machine.brandName != null && machine.brandName!.trim().isNotEmpty)
            ? machine.brandName!
            : exercise.equipmentCategory.label;
    final fullMachineTitle =
        showGymLocationName ? '$brandLabel • $gymName' : brandLabel;
    final colorScheme = Theme.of(context).colorScheme;

    // 1. Watch media specifically bound to this machine
    final mediaAsync = ref.watch(
      exerciseMediaListProvider((
        exerciseId: exercise.id,
        gymMachineId: machine.id,
      )),
    );
    final mediaList = mediaAsync.asData?.value ?? const [];
    final photoCount =
        mediaList.where((m) => m.mediaType == MediaType.photo).length;
    final videoCount =
        mediaList.where((m) => m.mediaType == MediaType.video).length;

    // 2. Watch PR summary specifically bound to this machine
    final prFilter = AnalyticsFilter(
      exerciseId: exercise.id,
      gymMachineId: machine.id,
    );
    final prAsync = ref.watch(exercisePRSummaryProvider(prFilter));
    final prSummary = prAsync.asData?.value;

    // 3. Watch last working set performance specifically bound to this machine
    final prevPerfAsync = ref.watch(
      previousExercisePerformanceProvider((
        exerciseId: exercise.id,
        gymMachineId: machine.id,
        excludeSessionId: null,
      )),
    );
    final prevPerf = prevPerfAsync.asData?.value;
    final lastWorkingSet =
        prevPerf != null && !prevPerf.isFromOtherGym && prevPerf.bySetNumber.isNotEmpty
            ? prevPerf.bySetNumber.values.first
            : null;

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

    final best1rm = prSummary?.bestEstimated1RM;
    final unitStr = _unitSuffix(machine.weightUnit);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Title, Brand/Machine, Unit Badge, Edit/Delete
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onTapHeader,
                    borderRadius: BorderRadius.circular(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showExerciseTitle ? exercise.name : brandLabel,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          showExerciseTitle
                              ? fullMachineTitle
                              : (showGymLocationName
                                  ? '$gymName • ${exercise.primaryMuscleGroup.label}'
                                  : exercise.primaryMuscleGroup.label),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    machine.weightUnit.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Edit Alat',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 19),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Hapus Alat',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 19),
                ),
              ],
            ),

            // Pinned Notes (Setting Kursi / Pin)
            if (machine.pinnedNotes != null &&
                machine.pinnedNotes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.7,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.push_pin_rounded,
                      size: 15,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
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

            // Machine-Specific 1RM & Working Set Summary Pill
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 15,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        best1rm != null
                            ? 'Est. 1RM Alat Ini: ${_formatNum(best1rm.value)} $unitStr'
                            : 'Est. 1RM Alat Ini: Belum ada',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  if (lastWorkingSet != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 15,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Working Set Terakhir: ${lastWorkingSet.formatInline(exercise.exerciseType)}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Inline Media Thumbnail Strip for this Machine (if any media exists)
            if (mediaList.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: mediaList.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final m = mediaList[idx];
                    final isVideo = m.mediaType == MediaType.video;
                    final thumbPath =
                        isVideo ? m.thumbnailLocalPath : m.localPath;
                    return InkWell(
                      onTap: () =>
                          _openMachineMediaSheet(context, fullMachineTitle),
                      borderRadius: BorderRadius.circular(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (thumbPath != null &&
                                  File(thumbPath).existsSync())
                                Image.file(
                                  File(thumbPath),
                                  fit: BoxFit.cover,
                                )
                              else
                                Container(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    isVideo
                                        ? Icons.videocam_outlined
                                        : Icons.image_outlined,
                                    size: 20,
                                  ),
                                ),
                              if (isVideo)
                                const Center(
                                  child: Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 10),
            // Action Buttons: Media Alat Ini & Progress/PR Alat Ini
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () =>
                      _openMachineMediaSheet(context, fullMachineTitle),
                  icon: const Icon(Icons.perm_media_outlined, size: 16),
                  label: Text(
                    'Foto/Video Alat ($photoCount Foto, $videoCount Video)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => ExerciseAnalyticsSheet.show(
                    context,
                    exerciseId: exercise.id,
                    gymMachineId: machine.id,
                  ),
                  icon: const Icon(Icons.insights_rounded, size: 16),
                  label: const Text(
                    'Progress & 1RM Alat Ini',
                    style: TextStyle(fontSize: 12),
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
