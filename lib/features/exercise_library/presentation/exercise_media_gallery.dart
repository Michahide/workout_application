import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/domain_labels.dart';
import '../../../core/database/tables.dart';
import '../data/exercise_library_repository.dart';
import 'exercise_library_providers.dart';

/// Displays the Exercise & Machine Media gallery (up to 4 Photos and 3 Videos
/// per specific [gymMachineId] or general exercise).
///
/// Architectural Rule:
/// - Video items in the grid MUST strictly render their compressed `.webp`
///   `thumbnailLocalPath` with a Play overlay icon and MUST NOT instantiate
///   a `VideoPlayerController` in the grid.
/// - `VideoPlayerController` is initialized ONLY inside the full-screen modal
///   when the user taps a video thumbnail.
class ExerciseMediaGallery extends ConsumerWidget {
  const ExerciseMediaGallery({
    super.key,
    required this.exerciseId,
    this.gymMachineId,
    this.machineTitle,
  });

  final String exerciseId;
  final String? gymMachineId;
  final String? machineTitle;

  Future<ImageSource?> _pickMediaSource(
    BuildContext context, {
    required String title,
  }) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                title,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil dari Kamera'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddPhoto(BuildContext context, WidgetRef ref) async {
    final source = await _pickMediaSource(
      context,
      title: 'Tambah Foto Alat / Setup (WebP 1080p)',
    );
    if (source == null || !context.mounted) return;

    try {
      await ref
          .read(
            exerciseMediaControllerProvider(exerciseId, gymMachineId).notifier,
          )
          .pickAndAddPhoto(source);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _handleAddVideo(BuildContext context, WidgetRef ref) async {
    final source = await _pickMediaSource(
      context,
      title: 'Tambah Video Alat / Form (720p MP4, Maks 30 dtk)',
    );
    if (source == null || !context.mounted) return;

    try {
      await ref
          .read(
            exerciseMediaControllerProvider(exerciseId, gymMachineId).notifier,
          )
          .pickAndAddVideo(source);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _confirmDeleteMedia(
    BuildContext context,
    WidgetRef ref,
    ExerciseMediaData media,
  ) async {
    final isVideo = media.mediaType == MediaType.video;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus ${isVideo ? "Video" : "Foto"}?'),
        content: const Text(
          'Media ini akan dihapus secara soft-delete dari database dan file fisiknya akan dihapus dari penyimpanan lokal.',
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
          .read(
            exerciseMediaControllerProvider(exerciseId, gymMachineId).notifier,
          )
          .deleteMedia(media.id);
    }
  }

  void _openMediaPreview(BuildContext context, ExerciseMediaData media) {
    if (media.mediaType == MediaType.photo) {
      showDialog<void>(
        context: context,
        builder: (_) => _FullScreenPhotoDialog(media: media),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (_) => _FullScreenVideoPlayerDialog(media: media),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(
      exerciseMediaListProvider((
        exerciseId: exerciseId,
        gymMachineId: gymMachineId,
      )),
    );
    final uploadState = ref.watch(
      exerciseMediaControllerProvider(exerciseId, gymMachineId),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return mediaAsync.when(
      data: (mediaItems) {
        final photos = mediaItems
            .where((m) => m.mediaType == MediaType.photo)
            .toList(growable: false);
        final videos = mediaItems
            .where((m) => m.mediaType == MediaType.video)
            .toList(growable: false);

        final canAddPhoto = !uploadState.isProcessing &&
            photos.length < ExerciseLibraryRepository.maxPhotosPerExercise;
        final canAddVideo = !uploadState.isProcessing &&
            videos.length < ExerciseLibraryRepository.maxVideosPerExercise;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  machineTitle != null
                      ? 'Foto & Video: $machineTitle'
                      : 'Foto & Video Umum Gerakan',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuotaBadge(
                      icon: Icons.photo_outlined,
                      label:
                          'Foto ${photos.length}/${ExerciseLibraryRepository.maxPhotosPerExercise}',
                      isFull: photos.length >=
                          ExerciseLibraryRepository.maxPhotosPerExercise,
                    ),
                    const SizedBox(width: 6),
                    _QuotaBadge(
                      icon: Icons.videocam_outlined,
                      label:
                          'Video ${videos.length}/${ExerciseLibraryRepository.maxVideosPerExercise}',
                      isFull: videos.length >=
                          ExerciseLibraryRepository.maxVideosPerExercise,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        canAddPhoto ? () => _handleAddPhoto(context, ref) : null,
                    icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                    label: const Text('Tambah Foto'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        canAddVideo ? () => _handleAddVideo(context, ref) : null,
                    icon: const Icon(Icons.video_call_outlined, size: 20),
                    label: const Text('Tambah Video'),
                  ),
                ),
              ],
            ),

            // Compression Progress Bar
            if (uploadState.isProcessing) ...[
              const SizedBox(height: 12),
              Card(
                color: colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              uploadState.activeMediaType == MediaType.video
                                  ? 'Mengompresi video ke 720p & membuat thumbnail WebP... '
                                      '${((uploadState.progress ?? 0) * 100).round()}%'
                                  : 'Mengompresi foto ke WebP (1080p)...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: uploadState.progress),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            if (mediaItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.perm_media_outlined,
                      size: 36,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada foto/video catatan form untuk gerakan ini.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mediaItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final media = mediaItems[index];
                  return _MediaGridTile(
                    media: media,
                    onTap: () => _openMediaPreview(context, media),
                    onDelete: () => _confirmDeleteMedia(context, ref, media),
                  );
                },
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Gagal memuat media: $err'),
    );
  }
}

class _QuotaBadge extends StatelessWidget {
  const _QuotaBadge({
    required this.icon,
    required this.label,
    required this.isFull,
  });

  final IconData icon;
  final String label;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFull
            ? colorScheme.errorContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isFull
                ? colorScheme.onErrorContainer
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isFull
                      ? colorScheme.onErrorContainer
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

/// Renders a single photo or video thumbnail tile in the grid.
/// For videos, strictly renders `thumbnailLocalPath` (.webp) with a Play icon
/// without instantiating `VideoPlayerController`.
class _MediaGridTile extends StatelessWidget {
  const _MediaGridTile({
    required this.media,
    required this.onTap,
    required this.onDelete,
  });

  final ExerciseMediaData media;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isVideo = media.mediaType == MediaType.video;
    final imagePath = isVideo ? media.thumbnailLocalPath : media.localPath;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null && File(imagePath).existsSync())
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              )
            else
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  isVideo
                      ? Icons.videocam_off_outlined
                      : Icons.broken_image_outlined,
                  size: 36,
                ),
              ),

            // Play Icon Overlay for Video Thumbnails
            if (isVideo)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

            // Bottom metadata bar (File Size & Duration)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatBytes(media.fileSizeBytes),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isVideo && media.durationSeconds != null)
                      Text(
                        '${media.durationSeconds}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Delete Button
            Positioned(
              top: 4,
              right: 4,
              child: IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenPhotoDialog extends StatelessWidget {
  const _FullScreenPhotoDialog({required this.media});

  final ExerciseMediaData media;

  @override
  Widget build(BuildContext context) {
    final file = File(media.localPath);
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.contain)
                  : const Text(
                      'File foto tidak ditemukan',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton.filledTonal(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 24,
            child: Text(
              'WebP • ${formatBytes(media.fileSizeBytes)}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

/// Initializes `VideoPlayerController` ONLY when opened in a full-screen dialog
/// and disposes it immediately when closed.
class _FullScreenVideoPlayerDialog extends StatefulWidget {
  const _FullScreenVideoPlayerDialog({required this.media});

  final ExerciseMediaData media;

  @override
  State<_FullScreenVideoPlayerDialog> createState() =>
      _FullScreenVideoPlayerDialogState();
}

class _FullScreenVideoPlayerDialogState
    extends State<_FullScreenVideoPlayerDialog> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final file = File(widget.media.localPath);
    if (!await file.exists()) {
      setState(() => _error = 'File video tidak ditemukan di penyimpanan lokal.');
      return;
    }

    final controller = VideoPlayerController.file(file);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Gagal memuat video: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: _error != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : !_isInitialized || controller == null
                      ? const CircularProgressIndicator()
                      : AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        ),
            ),
            if (_isInitialized && controller != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton.filledTonal(
                          onPressed: () {
                            setState(() {
                              if (controller.value.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                              }
                            });
                          },
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                        ),
                        Text(
                          '720p MP4 • ${formatBytes(widget.media.fileSizeBytes)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Positioned(
              top: 12,
              right: 16,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
