import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../database/syncable_table_mixin.dart';
import '../database/tables.dart';

part 'media_sync_service.g.dart';

/// Phase A & Lazy Downloader for Exercise Media files (`.webp` photos, `.mp4` videos,
/// and `.webp` video thumbnails).
class MediaSyncService {
  MediaSyncService(this._db);

  final AppDatabase _db;

  /// Phase A: Finds all active `ExerciseMedia` rows with `mediaSyncStatus == local_only`
  /// and `deletedAt == null`, uploads their physical files to `POST /api/v1/media/upload`,
  /// stores `remoteUrl` & `thumbnailRemoteUrl`, sets `mediaSyncStatus = uploaded`,
  /// and marks `syncStatus = pending_push` so metadata is sent in Phase B.
  Future<int> uploadPendingLocalMedia({
    required Dio dio,
    required String apiBaseUrl,
  }) async {
    final pendingMedia = await (_db.select(_db.exerciseMedia)
          ..where(
            (tbl) =>
                tbl.mediaSyncStatus.equals(MediaSyncStatus.local_only.name) &
                tbl.deletedAt.isNull(),
          ))
        .get();

    if (pendingMedia.isEmpty) return 0;
    var uploadedCount = 0;

    for (final item in pendingMedia) {
      final mainFile = File(item.localPath);
      if (!await mainFile.exists()) {
        continue;
      }

      // 1. Mark status as uploading
      await (_db.update(_db.exerciseMedia)
            ..where((tbl) => tbl.id.equals(item.id)))
          .write(
        const ExerciseMediaCompanion(
          mediaSyncStatus: Value(MediaSyncStatus.uploading),
        ),
      );

      try {
        final formMap = <String, dynamic>{
          'media_id': item.id,
          'exercise_id': item.exerciseId,
          'media_type': item.mediaType.name,
          'file': await MultipartFile.fromFile(
            mainFile.path,
            filename: p.basename(mainFile.path),
          ),
        };

        if (item.mediaType == MediaType.video &&
            item.thumbnailLocalPath != null &&
            item.thumbnailLocalPath!.isNotEmpty) {
          final thumbFile = File(item.thumbnailLocalPath!);
          if (await thumbFile.exists()) {
            formMap['thumbnail'] = await MultipartFile.fromFile(
              thumbFile.path,
              filename: p.basename(thumbFile.path),
            );
          }
        }

        // 2. Upload via Multipart POST to /api/v1/media/upload
        final response = await dio.post<Map<String, dynamic>>(
          '$apiBaseUrl/api/v1/media/upload',
          data: FormData.fromMap(formMap),
        );

        final data = response.data ?? const <String, dynamic>{};
        final remoteUrl = (data['remote_url'] ?? data['remoteUrl']) as String?;
        final thumbRemoteUrl = (data['thumbnail_remote_url'] ??
            data['thumbnailRemoteUrl']) as String?;

        if (remoteUrl == null || remoteUrl.isEmpty) {
          throw const FormatException(
            'Response server tidak menyertakan remote_url.',
          );
        }

        // 3. Update local row with remote URLs, mediaSyncStatus = uploaded, syncStatus = pendingPush
        final now = DateTime.now().toUtc();
        await (_db.update(_db.exerciseMedia)
              ..where((tbl) => tbl.id.equals(item.id)))
            .write(
          ExerciseMediaCompanion(
            remoteUrl: Value(remoteUrl),
            thumbnailRemoteUrl: Value(thumbRemoteUrl),
            mediaSyncStatus: const Value(MediaSyncStatus.uploaded),
            updatedAt: Value(now),
            syncStatus: Value(SyncStatus.pendingPush),
          ),
        );
        uploadedCount++;
      } catch (_) {
        // Revert to local_only so it can be retried on the next sync run
        await (_db.update(_db.exerciseMedia)
              ..where((tbl) => tbl.id.equals(item.id)))
            .write(
          const ExerciseMediaCompanion(
            mediaSyncStatus: Value(MediaSyncStatus.local_only),
          ),
        );
        rethrow;
      }
    }

    return uploadedCount;
  }

  /// Lazy Media Downloader: Downloads any active `ExerciseMedia` records pulled
  /// from the cloud whose local files do not yet exist on this device.
  Future<int> downloadMissingCloudMedia({required Dio dio}) async {
    final activeRemoteMedia = await (_db.select(_db.exerciseMedia)
          ..where(
            (tbl) => tbl.deletedAt.isNull() & tbl.remoteUrl.isNotNull(),
          ))
        .get();

    if (activeRemoteMedia.isEmpty) return 0;

    final docsDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(docsDir.path, 'exercise_media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    var downloadedCount = 0;

    for (final item in activeRemoteMedia) {
      final hasLocalMain =
          item.localPath.isNotEmpty && File(item.localPath).existsSync();
      final needsThumb = item.mediaType == MediaType.video &&
          item.thumbnailRemoteUrl != null &&
          item.thumbnailRemoteUrl!.isNotEmpty;
      final hasLocalThumb = !needsThumb ||
          (item.thumbnailLocalPath != null &&
              item.thumbnailLocalPath!.isNotEmpty &&
              File(item.thumbnailLocalPath!).existsSync());

      if (hasLocalMain && hasLocalThumb) {
        continue;
      }

      var newLocalPath = item.localPath;
      var newThumbPath = item.thumbnailLocalPath;

      if (!hasLocalMain && item.remoteUrl != null) {
        final ext = item.mediaType == MediaType.video ? '.mp4' : '.webp';
        final targetMain = p.join(
          mediaDir.path,
          '${item.mediaType.name}_${item.id}$ext',
        );
        await dio.download(item.remoteUrl!, targetMain);
        newLocalPath = targetMain;
      }

      if (!hasLocalThumb && item.thumbnailRemoteUrl != null) {
        final targetThumb = p.join(mediaDir.path, 'thumb_${item.id}.webp');
        await dio.download(item.thumbnailRemoteUrl!, targetThumb);
        newThumbPath = targetThumb;
      }

      await (_db.update(_db.exerciseMedia)
            ..where((tbl) => tbl.id.equals(item.id)))
          .write(
        ExerciseMediaCompanion(
          localPath: Value(newLocalPath),
          thumbnailLocalPath: Value(newThumbPath),
          mediaSyncStatus: const Value(MediaSyncStatus.uploaded),
          syncStatus: const Value(SyncStatus.synced),
        ),
      );
      downloadedCount++;
    }

    return downloadedCount;
  }
}

@Riverpod(keepAlive: true)
MediaSyncService mediaSyncService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return MediaSyncService(db);
}
