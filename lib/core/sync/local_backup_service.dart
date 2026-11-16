import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

part 'local_backup_service.g.dart';

/// Exception thrown when exporting or restoring a local `.zip` backup fails.
class LocalBackupException implements Exception {
  const LocalBackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Service for creating and restoring full offline `.zip` backups containing:
/// - `workout_tracker.sqlite` (all Drift tables, history, PRs, plans, settings)
/// - `exercise_media/*` (all compressed `.webp` photos, `.mp4` videos, and thumbnails)
class LocalBackupService {
  static const String _kDatabaseFileName = 'workout_tracker.sqlite';
  static const String _kMediaFolderName = 'exercise_media';
  static const String _kManifestFileName = 'backup_manifest.json';

  /// Creates a `.zip` archive of the SQLite database and `exercise_media/` folder,
  /// then opens the native share sheet via `SharePlus.instance.share`.
  Future<String> exportFullBackupZip(AppDatabase db) async {
    // Flush WAL to main SQLite file before reading bytes
    try {
      await db.customStatement('PRAGMA wal_checkpoint(FULL)');
    } catch (_) {
      // Ignore if WAL mode is not active.
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docsDir.path, _kDatabaseFileName));
    if (!await dbFile.exists()) {
      throw const LocalBackupException(
        'File database lokal belum tersedia untuk di-export.',
      );
    }

    final archive = Archive();

    // 1. Add SQLite database file
    final dbBytes = await dbFile.readAsBytes();
    archive.addFile(ArchiveFile.bytes(_kDatabaseFileName, dbBytes));

    // 2. Add all files in exercise_media/
    var mediaFileCount = 0;
    final mediaDir = Directory(p.join(docsDir.path, _kMediaFolderName));
    if (await mediaDir.exists()) {
      await for (final entity in mediaDir.list(recursive: false)) {
        if (entity is File) {
          final fileBytes = await entity.readAsBytes();
          final entryName =
              '$_kMediaFolderName/${p.basename(entity.path)}';
          archive.addFile(ArchiveFile.bytes(entryName, fileBytes));
          mediaFileCount++;
        }
      }
    }

    // 3. Add backup manifest metadata
    final manifestJson = jsonEncode({
      'app': 'workout_application',
      'schema_version': db.schemaVersion,
      'exported_at_utc': DateTime.now().toUtc().toIso8601String(),
      'media_files_count': mediaFileCount,
    });
    archive.addFile(ArchiveFile.string(_kManifestFileName, manifestJson));

    // 4. Encode ZIP and save to temporary directory
    final zipBytes = ZipEncoder().encode(archive);
    final tempDir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final zipFilePath = p.join(tempDir.path, 'workout_backup_$stamp.zip');
    final zipFile = File(zipFilePath);
    await zipFile.writeAsBytes(zipBytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(zipFile.path)],
        text: 'Workout Tracker Full Offline Backup ($stamp)',
      ),
    );

    return zipFile.path;
  }

  /// Prompts the user to pick a `.zip` backup file, validates its contents,
  /// closes the active `AppDatabase`, overwrites `workout_tracker.sqlite` and
  /// `exercise_media/`, repairs media paths for the current device directory,
  /// and invalidates `appDatabaseProvider` so all Riverpod streams refresh.
  ///
  /// Returns `true` if a backup was restored, or `false` if the user cancelled.
  Future<bool> importFullBackupZip(WidgetRef ref) async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Pilih File Backup (.zip)',
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );

    if (picked == null) {
      return false;
    }

    final zipBytes = await picked.readAsBytes();

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } catch (e) {
      throw LocalBackupException('File .zip rusak atau tidak valid: $e');
    }

    final dbEntry = archive.files
        .where((f) => f.isFile && p.basename(f.name) == _kDatabaseFileName)
        .firstOrNull;
    if (dbEntry == null) {
      throw const LocalBackupException(
        'Backup tidak valid: file workout_tracker.sqlite tidak ditemukan di dalam .zip.',
      );
    }

    final dbContentBytes = dbEntry.readBytes();
    if (dbContentBytes == null || dbContentBytes.isEmpty) {
      throw const LocalBackupException(
        'File database di dalam .zip kosong.',
      );
    }

    // 1. Close current AppDatabase connection safely
    final currentDb = ref.read(appDatabaseProvider);
    await currentDb.close();

    final docsDir = await getApplicationDocumentsDirectory();
    final targetDbPath = p.join(docsDir.path, _kDatabaseFileName);

    // Remove WAL / SHM sidecar files if present
    for (final suffix in ['', '-wal', '-shm']) {
      final f = File('$targetDbPath$suffix');
      if (await f.exists()) {
        await f.delete();
      }
    }

    // 2. Write restored SQLite file
    await File(targetDbPath).writeAsBytes(dbContentBytes, flush: true);

    // 3. Restore exercise_media/ folder
    final targetMediaDir = Directory(p.join(docsDir.path, _kMediaFolderName));
    if (await targetMediaDir.exists()) {
      await targetMediaDir.delete(recursive: true);
    }
    await targetMediaDir.create(recursive: true);

    for (final entry in archive.files) {
      if (!entry.isFile) continue;
      final normalized = entry.name.replaceAll('\\', '/');
      if (!normalized.startsWith('$_kMediaFolderName/')) continue;

      final safeFileName = p.basename(normalized);
      if (safeFileName.isEmpty || safeFileName.startsWith('.')) continue;

      final bytes = entry.readBytes();
      if (bytes == null) continue;

      final destFile = File(p.join(targetMediaDir.path, safeFileName));
      await destFile.writeAsBytes(bytes, flush: true);
    }

    // 4. Re-initialize AppDatabase by invalidating the provider and repair local media paths
    ref.invalidate(appDatabaseProvider);
    final newDb = ref.read(appDatabaseProvider);
    await _rebindRestoredMediaPaths(newDb, targetMediaDir.path);

    return true;
  }

  /// Ensures `localPath` and `thumbnailLocalPath` in `ExerciseMedia` point to
  /// the current device's `ApplicationDocumentsDirectory/exercise_media/` folder
  /// in case the backup came from a different phone/OS path.
  Future<void> _rebindRestoredMediaPaths(
    AppDatabase db,
    String mediaDirPath,
  ) async {
    final allMedia = await db.select(db.exerciseMedia).get();
    for (final item in allMedia) {
      final mainName = p.basename(item.localPath);
      final updatedMainPath =
          mainName.isNotEmpty ? p.join(mediaDirPath, mainName) : item.localPath;

      String? updatedThumbPath = item.thumbnailLocalPath;
      if (item.thumbnailLocalPath != null &&
          item.thumbnailLocalPath!.isNotEmpty) {
        final thumbName = p.basename(item.thumbnailLocalPath!);
        updatedThumbPath = p.join(mediaDirPath, thumbName);
      }

      if (updatedMainPath != item.localPath ||
          updatedThumbPath != item.thumbnailLocalPath) {
        await (db.update(db.exerciseMedia)
              ..where((t) => t.id.equals(item.id)))
            .write(
          ExerciseMediaCompanion(
            localPath: Value(updatedMainPath),
            thumbnailLocalPath: Value(updatedThumbPath),
          ),
        );
      }
    }
  }
}

@Riverpod(keepAlive: true)
LocalBackupService localBackupService(Ref ref) {
  return LocalBackupService();
}
