import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/tables.dart';
import '../../exercise_library/presentation/exercise_library_providers.dart';

/// Displays a rounded photo/video thumbnail preview for a specific [gymMachineId]
/// (or general [exerciseId] if [gymMachineId] is null) so the user can visually
/// identify the exact gym machine alongside its brand name and gym location.
class MachineThumbnailAvatar extends ConsumerWidget {
  const MachineThumbnailAvatar({
    super.key,
    required this.exerciseId,
    required this.gymMachineId,
    this.size = 52,
    this.placeholderIcon = Icons.precision_manufacturing_outlined,
    this.onTap,
  });

  final String exerciseId;
  final String? gymMachineId;
  final double size;
  final IconData placeholderIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    if (gymMachineId == null || gymMachineId!.isEmpty) {
      return _buildPlaceholder(colorScheme, Icons.public_rounded);
    }

    final mediaAsync = ref.watch(
      exerciseMediaListProvider((
        exerciseId: exerciseId,
        gymMachineId: gymMachineId,
      )),
    );

    final mediaList = mediaAsync.asData?.value ?? const [];
    final firstMedia = mediaList.firstOrNull;
    final isVideo = firstMedia?.mediaType == MediaType.video;
    final imagePath = firstMedia == null
        ? null
        : (isVideo ? firstMedia.thumbnailLocalPath : firstMedia.localPath);

    final hasValidFile =
        imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync();

    final child = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: hasValidFile
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                  if (isVideo)
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  if (mediaList.length > 1)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${mediaList.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : _buildPlaceholder(colorScheme, placeholderIcon),
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: child,
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme, IconData icon) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Icon(
        icon,
        size: size * 0.44,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
