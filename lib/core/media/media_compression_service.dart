import 'dart:async';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

part 'media_compression_service.g.dart';

/// Exception thrown when media picking, validation, or compression fails.
class MediaCompressionException implements Exception {
  const MediaCompressionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Metadata returned after compressing and saving a photo locally.
class CompressedPhotoResult {
  const CompressedPhotoResult({
    required this.localPath,
    required this.fileSizeBytes,
  });

  final String localPath;
  final int fileSizeBytes;
}

/// Metadata returned after compressing and saving a video and its WebP thumbnail locally.
class CompressedVideoResult {
  const CompressedVideoResult({
    required this.localPath,
    required this.thumbnailLocalPath,
    required this.fileSizeBytes,
    required this.durationSeconds,
  });

  final String localPath;
  final String thumbnailLocalPath;
  final int fileSizeBytes;
  final int durationSeconds;
}

/// Handles picking, validating, compressing, and storing exercise media files
/// inside `ApplicationDocumentsDirectory/exercise_media/`.
class MediaCompressionService {
  MediaCompressionService({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;
  static const _uuid = Uuid();
  static const int maxVideoDurationSeconds = 30;
  static const int maxAllowedVideoToleranceSeconds = 35;

  /// Broadcast stream of video compression progress normalized to `0.0 - 1.0`.
  Stream<double> get videoCompressionProgressStream {
    late final StreamController<double> controller;
    Subscription? subscription;

    controller = StreamController<double>.broadcast(
      onListen: () {
        subscription = VideoCompress.compressProgress$.subscribe((progress) {
          if (!controller.isClosed) {
            controller.add((progress / 100.0).clamp(0.0, 1.0));
          }
        });
      },
      onCancel: () {
        subscription?.unsubscribe();
        subscription = null;
      },
    );

    return controller.stream;
  }

  Future<Directory> _ensureMediaDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(docsDir.path, 'exercise_media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir;
  }

  /// Picks a photo from [source], compresses it to max 1080px WebP (quality 75),
  /// saves it to `ApplicationDocumentsDirectory/exercise_media/`, deletes the
  /// temporary source file from `image_picker`, and returns [CompressedPhotoResult].
  ///
  /// Returns `null` if the user cancels the picker.
  Future<CompressedPhotoResult?> compressAndSavePhoto({
    ImageSource source = ImageSource.gallery,
  }) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile == null) {
      return null;
    }

    final mediaDir = await _ensureMediaDirectory();
    final fileId = _uuid.v4();
    final targetPath = p.join(mediaDir.path, 'photo_$fileId.webp');

    try {
      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        minWidth: 1080,
        minHeight: 1080,
        quality: 75,
        format: CompressFormat.webp,
      );

      if (compressedXFile == null) {
        throw const MediaCompressionException(
          'Gagal mengompresi foto ke format WebP.',
        );
      }

      final savedFile = File(compressedXFile.path);
      final fileSizeBytes = await savedFile.length();

      return CompressedPhotoResult(
        localPath: savedFile.path,
        fileSizeBytes: fileSizeBytes,
      );
    } finally {
      await _safeDeleteFile(pickedFile.path, excludePath: targetPath);
    }
  }

  /// Picks a video from [source] (max 30s), validates duration (<= 35s),
  /// transcodes to 720p MediumQuality MP4 while reporting progress (0.0 - 1.0),
  /// extracts a frame and compresses it to a 480px WebP thumbnail, moves both
  /// to `ApplicationDocumentsDirectory/exercise_media/`, and cleans up temp cache.
  ///
  /// Returns `null` if the user cancels the picker.
  Future<CompressedVideoResult?> compressAndSaveVideo({
    ImageSource source = ImageSource.gallery,
    void Function(double progress)? onProgress,
  }) async {
    final pickedFile = await _imagePicker.pickVideo(
      source: source,
      maxDuration: const Duration(seconds: maxVideoDurationSeconds),
    );
    if (pickedFile == null) {
      return null;
    }

    Subscription? progressSub;
    File? rawThumbFile;

    try {
      final rawInfo = await VideoCompress.getMediaInfo(pickedFile.path);
      final durationMs = rawInfo.duration ?? 0;
      final durationSeconds = (durationMs / 1000).round();

      if (durationSeconds > maxAllowedVideoToleranceSeconds) {
        throw MediaCompressionException(
          'Durasi video ($durationSeconds detik) melebihi batas maksimal '
          '$maxVideoDurationSeconds detik. Silakan potong video terlebih dahulu.',
        );
      }

      if (onProgress != null) {
        onProgress(0.0);
        progressSub = VideoCompress.compressProgress$.subscribe((progress) {
          onProgress((progress / 100.0).clamp(0.0, 1.0));
        });
      }

      final compressedInfo = await VideoCompress.compressVideo(
        pickedFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 30,
      );

      final compressedVideoFile = compressedInfo?.file;
      if (compressedVideoFile == null || !await compressedVideoFile.exists()) {
        throw const MediaCompressionException(
          'Gagal mengompresi video ke resolusi 720p.',
        );
      }

      // Extract a frame from the video and compress it into a 480px WebP thumbnail
      rawThumbFile = await VideoCompress.getFileThumbnail(
        pickedFile.path,
        quality: 80,
        position: -1,
      );

      final mediaDir = await _ensureMediaDirectory();
      final fileId = _uuid.v4();
      final permanentVideoPath = p.join(mediaDir.path, 'video_$fileId.mp4');
      final permanentThumbPath = p.join(mediaDir.path, 'thumb_$fileId.webp');

      final compressedThumbXFile =
          await FlutterImageCompress.compressAndGetFile(
        rawThumbFile.path,
        permanentThumbPath,
        minWidth: 480,
        minHeight: 480,
        quality: 70,
        format: CompressFormat.webp,
      );

      if (compressedThumbXFile == null) {
        throw const MediaCompressionException(
          'Gagal membuat thumbnail WebP dari video.',
        );
      }

      final permanentVideoFile = await _moveOrCopyFile(
        compressedVideoFile,
        permanentVideoPath,
      );
      final fileSizeBytes = await permanentVideoFile.length();
      final finalDurationSeconds =
          ((compressedInfo?.duration ?? durationMs) / 1000).round().clamp(1, 35);

      onProgress?.call(1.0);

      return CompressedVideoResult(
        localPath: permanentVideoFile.path,
        thumbnailLocalPath: compressedThumbXFile.path,
        fileSizeBytes: fileSizeBytes,
        durationSeconds: finalDurationSeconds,
      );
    } finally {
      progressSub?.unsubscribe();
      await _safeDeleteFile(pickedFile.path);
      if (rawThumbFile != null) {
        await _safeDeleteFile(rawThumbFile.path);
      }
      try {
        await VideoCompress.deleteAllCache();
      } catch (_) {
        // Ignore cache cleanup errors.
      }
    }
  }

  /// Deletes the physical `.webp` / `.mp4` file and its optional WebP thumbnail
  /// from local storage when an exercise media item is deleted by the user.
  Future<void> deleteLocalMediaFile({
    required String localPath,
    String? thumbnailLocalPath,
  }) async {
    await _safeDeleteFile(localPath);
    if (thumbnailLocalPath != null && thumbnailLocalPath.isNotEmpty) {
      await _safeDeleteFile(thumbnailLocalPath);
    }
  }

  Future<File> _moveOrCopyFile(File source, String targetPath) async {
    try {
      return await source.rename(targetPath);
    } on FileSystemException {
      final copied = await source.copy(targetPath);
      await _safeDeleteFile(source.path, excludePath: targetPath);
      return copied;
    }
  }

  Future<void> _safeDeleteFile(String path, {String? excludePath}) async {
    if (path.isEmpty) return;
    if (excludePath != null && p.equals(path, excludePath)) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore cleanup errors on temp files.
    }
  }
}

@Riverpod(keepAlive: true)
MediaCompressionService mediaCompressionService(Ref ref) {
  return MediaCompressionService();
}
