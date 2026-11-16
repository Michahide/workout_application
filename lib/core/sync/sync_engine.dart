// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../database/syncable_table_mixin.dart';
import '../database/tables.dart';
import '../media/media_compression_service.dart';
import 'media_sync_service.dart';
import 'sync_preferences_service.dart';

part 'sync_engine.g.dart';

/// Overall state of the Cloud Sync Engine.
enum CloudSyncPhase {
  idle,
  uploadingMedia,
  pushingOutbox,
  pullingDelta,
  synced,
  offline,
  error,
}

/// Immutable UI & diagnostic state managed by [SyncController].
class SyncEngineState {
  const SyncEngineState({
    this.phase = CloudSyncPhase.idle,
    this.isSyncing = false,
    this.isOnline = true,
    this.apiBaseUrl = '',
    this.authToken = '',
    this.lastSyncedAt,
    this.errorMessage,
  });

  final CloudSyncPhase phase;
  final bool isSyncing;
  final bool isOnline;
  final String apiBaseUrl;
  final String authToken;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  bool get isConfigured => apiBaseUrl.trim().isNotEmpty;

  SyncEngineState copyWith({
    CloudSyncPhase? phase,
    bool? isSyncing,
    bool? isOnline,
    String? apiBaseUrl,
    String? authToken,
    DateTime? Function()? lastSyncedAt,
    String? Function()? errorMessage,
  }) {
    return SyncEngineState(
      phase: phase ?? this.phase,
      isSyncing: isSyncing ?? this.isSyncing,
      isOnline: isOnline ?? this.isOnline,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      authToken: authToken ?? this.authToken,
      lastSyncedAt:
          lastSyncedAt != null ? lastSyncedAt() : this.lastSyncedAt,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

/// Core 3-phase Cloud Synchronization Engine:
/// - Phase A: Media Upload (`MediaSyncService`)
/// - Phase B: Outbox Batch Push in strict Foreign Key Dependency Order (1..10)
/// - Phase C: Delta Pull with Last-Write-Wins (LWW) conflict resolution & Lazy Media Download
class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    required MediaSyncService mediaSyncService,
    required MediaCompressionService mediaCompressionService,
    required SyncPreferencesService preferencesService,
    Dio? dio,
  })  : _db = db,
        _mediaSyncService = mediaSyncService,
        _mediaCompressionService = mediaCompressionService,
        _preferencesService = preferencesService,
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
              ),
            );

  final AppDatabase _db;
  final MediaSyncService _mediaSyncService;
  final MediaCompressionService _mediaCompressionService;
  final SyncPreferencesService _preferencesService;
  final Dio _dio;

  /// Mutex lock preventing concurrent overlapping sync runs.
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// Strict Foreign Key Dependency Order (Parent -> Child, 1 to 10)
  /// required for both Outbox Batch Push and Delta Pull Upserts.
  static const List<String> kForeignKeyEntityOrder = [
    'app_settings',
    'gym_locations',
    'exercises',
    'gym_machines',
    'exercise_media',
    'workout_plans',
    'workout_plan_exercises',
    'workout_sessions',
    'workout_session_exercises',
    'workout_sets',
  ];

  /// Pure Last-Write-Wins (LWW) conflict resolution function.
  ///
  /// - If the local record has unsynced changes (`pending_push` or `pending_delete`),
  ///   the remote record is accepted ONLY IF `remoteUpdatedAt` is strictly after
  ///   `localUpdatedAt`.
  /// - If the local record is already `synced`, the remote update is accepted
  ///   whenever `remoteUpdatedAt >= localUpdatedAt`.
  static bool shouldAcceptRemoteByLastWriteWins({
    required SyncStatus localSyncStatus,
    required DateTime localUpdatedAt,
    required DateTime remoteUpdatedAt,
  }) {
    final localUtc = localUpdatedAt.toUtc();
    final remoteUtc = remoteUpdatedAt.toUtc();

    if (localSyncStatus == SyncStatus.pending_push ||
        localSyncStatus == SyncStatus.pending_delete) {
      return remoteUtc.isAfter(localUtc);
    }

    return remoteUtc.isAfter(localUtc) ||
        remoteUtc.isAtSameMomentAs(localUtc);
  }

  /// Orders any raw map of entity lists into the strict 1..10 Foreign Key Dependency Order.
  static Map<String, List<Map<String, dynamic>>> orderPayloadByForeignKey(
    Map<String, List<Map<String, dynamic>>> unordered,
  ) {
    final ordered = <String, List<Map<String, dynamic>>>{};
    for (final key in kForeignKeyEntityOrder) {
      ordered[key] = unordered[key] ?? const <Map<String, dynamic>>[];
    }
    return ordered;
  }

  /// Watches the total number of pending outbox records across all 10 tables
  /// (excluding in-progress active workout sessions).
  Stream<int> watchPendingOutboxCount() {
    final triggerStreams = <Stream<dynamic>>[
      _db.select(_db.appSettings).watch(),
      _db.select(_db.gymLocations).watch(),
      _db.select(_db.exercises).watch(),
      _db.select(_db.gymMachines).watch(),
      _db.select(_db.exerciseMedia).watch(),
      _db.select(_db.workoutPlans).watch(),
      _db.select(_db.workoutPlanExercises).watch(),
      _db.select(_db.workoutSessions).watch(),
      _db.select(_db.workoutSessionExercises).watch(),
      _db.select(_db.workoutSets).watch(),
    ];

    late final StreamController<void> controller;
    final subscriptions = <StreamSubscription<dynamic>>[];

    controller = StreamController<void>.broadcast(
      onListen: () {
        controller.add(null);
        for (final s in triggerStreams) {
          subscriptions.add(
            s.listen((_) {
              if (!controller.isClosed) controller.add(null);
            }),
          );
        }
      },
      onCancel: () {
        for (final sub in subscriptions) {
          sub.cancel();
        }
        subscriptions.clear();
      },
    );

    return controller.stream.asyncMap((_) async {
      final outbox = await collectOutboxBatch();
      var total = 0;
      for (final list in outbox.payload.values) {
        total += list.length;
      }
      return total;
    });
  }

  /// Runs all 3 synchronization phases sequentially under a mutex lock (`_isSyncing`).
  Future<DateTime?> syncAll({
    void Function(CloudSyncPhase phase)? onPhaseChanged,
  }) async {
    if (_isSyncing) return null;
    _isSyncing = true;

    try {
      final config = await _preferencesService.getConfig();
      if (!config.isConfigured) {
        return config.lastSyncTimestamp;
      }

      _configureAuthHeader(config.authToken);

      // Phase A: Upload pending local media files (.webp / .mp4)
      onPhaseChanged?.call(CloudSyncPhase.uploadingMedia);
      await _mediaSyncService.uploadPendingLocalMedia(
        dio: _dio,
        apiBaseUrl: config.apiBaseUrl,
      );

      // Phase B: Push pending metadata outbox in strict FK order (1..10)
      onPhaseChanged?.call(CloudSyncPhase.pushingOutbox);
      await pushPendingChanges(apiBaseUrl: config.apiBaseUrl);

      // Phase C: Pull remote delta since lastSyncTimestamp & apply LWW upserts
      onPhaseChanged?.call(CloudSyncPhase.pullingDelta);
      final newSyncTime = await pullRemoteChanges(
        apiBaseUrl: config.apiBaseUrl,
        lastSyncTimestamp: config.lastSyncTimestamp,
      );

      // Lazy download any missing cloud media files pulled in Phase C
      await _mediaSyncService.downloadMissingCloudMedia(dio: _dio);

      onPhaseChanged?.call(CloudSyncPhase.synced);
      return newSyncTime;
    } finally {
      _isSyncing = false;
    }
  }

  void _configureAuthHeader(String token) {
    if (token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // ---------------------------------------------------------------------------
  // PHASE B: OUTBOX BATCH PUSH
  // ---------------------------------------------------------------------------

  bool _isPendingStatus(SyncStatus status) =>
      status == SyncStatus.pending_push || status == SyncStatus.pending_delete;

  /// Collects all local records with `pending_push` or `pending_delete` ordered
  /// strictly from parent to child (`kForeignKeyEntityOrder`), while excluding
  /// any currently active workout session (`completedAt == null && deletedAt == null`).
  Future<({
    Map<String, List<Map<String, dynamic>>> payload,
    Map<String, Map<String, DateTime>> snapshotUpdatedAt,
  })> collectOutboxBatch() async {
    // Identify active (in-progress) workout sessions to protect from premature push
    final activeSessions = await (_db.select(_db.workoutSessions)
          ..where((tbl) => tbl.completedAt.isNull() & tbl.deletedAt.isNull()))
        .get();
    final activeSessionIds = activeSessions.map((s) => s.id).toSet();

    final activeSessionExercises = activeSessionIds.isEmpty
        ? const <WorkoutSessionExercise>[]
        : await (_db.select(_db.workoutSessionExercises)
              ..where((tbl) => tbl.workoutSessionId.isIn(activeSessionIds)))
            .get();
    final activeSeIds = activeSessionExercises.map((se) => se.id).toSet();

    final snapshot = <String, Map<String, DateTime>>{
      for (final table in kForeignKeyEntityOrder) table: <String, DateTime>{},
    };
    final unordered = <String, List<Map<String, dynamic>>>{};

    // 1. app_settings
    final settingsRows = (await _db.select(_db.appSettings).get())
        .where((r) => _isPendingStatus(r.syncStatus))
        .toList(growable: false);
    unordered['app_settings'] = settingsRows.map((r) {
      snapshot['app_settings']![r.id] = r.updatedAt;
      return _serializeAppSetting(r);
    }).toList(growable: false);

    // 2. gym_locations
    final gymRows = (await _db.select(_db.gymLocations).get())
        .where((r) => _isPendingStatus(r.syncStatus))
        .toList(growable: false);
    unordered['gym_locations'] = gymRows.map((r) {
      snapshot['gym_locations']![r.id] = r.updatedAt;
      return _serializeGymLocation(r);
    }).toList(growable: false);

    // 3. exercises
    final exerciseRows = (await _db.select(_db.exercises).get())
        .where((r) => _isPendingStatus(r.syncStatus))
        .toList(growable: false);
    unordered['exercises'] = exerciseRows.map((r) {
      snapshot['exercises']![r.id] = r.updatedAt;
      return _serializeExercise(r);
    }).toList(growable: false);

    // 4. gym_machines
    final machineRows = (await _db.select(_db.gymMachines).get())
        .where((r) => _isPendingStatus(r.syncStatus))
        .toList(growable: false);
    unordered['gym_machines'] = machineRows.map((r) {
      snapshot['gym_machines']![r.id] = r.updatedAt;
      return _serializeGymMachine(r);
    }).toList(growable: false);

    // 5. exercise_media (only push metadata once mediaSyncStatus is uploaded or soft-deleted)
    final mediaRows = (await _db.select(_db.exerciseMedia).get())
        .where(
          (r) =>
              _isPendingStatus(r.syncStatus) &&
              (r.deletedAt != null ||
                  r.mediaSyncStatus == MediaSyncStatus.uploaded),
        )
        .toList(growable: false);
    unordered['exercise_media'] = mediaRows.map((r) {
      snapshot['exercise_media']![r.id] = r.updatedAt;
      return _serializeExerciseMedia(r);
    }).toList(growable: false);

    // 6. workout_plans
    final planRows = (await _db.select(_db.workoutPlans).get())
        .where((r) => _isPendingStatus(r.syncStatus))
        .toList(growable: false);
    unordered['workout_plans'] = planRows.map((r) {
      snapshot['workout_plans']![r.id] = r.updatedAt;
      return _serializeWorkoutPlan(r);
    }).toList(growable: false);

    // 7. workout_plan_exercises
    final planExRows = (await _db.select(_db.workoutPlanExercises).get())
        .where((r) => _isPendingStatus(r.syncStatus))
        .toList(growable: false);
    unordered['workout_plan_exercises'] = planExRows.map((r) {
      snapshot['workout_plan_exercises']![r.id] = r.updatedAt;
      return _serializeWorkoutPlanExercise(r);
    }).toList(growable: false);

    // 8. workout_sessions (exclude active in-progress sessions)
    final sessionRows = (await _db.select(_db.workoutSessions).get())
        .where(
          (r) =>
              _isPendingStatus(r.syncStatus) &&
              !activeSessionIds.contains(r.id),
        )
        .toList(growable: false);
    unordered['workout_sessions'] = sessionRows.map((r) {
      snapshot['workout_sessions']![r.id] = r.updatedAt;
      return _serializeWorkoutSession(r);
    }).toList(growable: false);

    // 9. workout_session_exercises (exclude active in-progress sessions)
    final sessionExRows = (await _db.select(_db.workoutSessionExercises).get())
        .where(
          (r) =>
              _isPendingStatus(r.syncStatus) &&
              !activeSessionIds.contains(r.workoutSessionId),
        )
        .toList(growable: false);
    unordered['workout_session_exercises'] = sessionExRows.map((r) {
      snapshot['workout_session_exercises']![r.id] = r.updatedAt;
      return _serializeWorkoutSessionExercise(r);
    }).toList(growable: false);

    // 10. workout_sets (exclude active in-progress sessions)
    final setRows = (await _db.select(_db.workoutSets).get())
        .where(
          (r) =>
              _isPendingStatus(r.syncStatus) &&
              !activeSeIds.contains(r.workoutSessionExerciseId),
        )
        .toList(growable: false);
    unordered['workout_sets'] = setRows.map((r) {
      snapshot['workout_sets']![r.id] = r.updatedAt;
      return _serializeWorkoutSet(r);
    }).toList(growable: false);

    return (
      payload: orderPayloadByForeignKey(unordered),
      snapshotUpdatedAt: snapshot,
    );
  }

  /// Sends pending outbox changes to `POST /api/v1/sync/push` and marks
  /// acknowledged records as `SyncStatus.synced` if their local `updatedAt`
  /// did not change during the request.
  Future<void> pushPendingChanges({required String apiBaseUrl}) async {
    final outbox = await collectOutboxBatch();
    final hasAnyChanges =
        outbox.payload.values.any((records) => records.isNotEmpty);
    if (!hasAnyChanges) return;

    final response = await _dio.post<Map<String, dynamic>>(
      '$apiBaseUrl/api/v1/sync/push',
      data: {
        'changes': outbox.payload,
      },
    );

    final responseData = response.data ?? const <String, dynamic>{};
    final ackRaw = responseData['acknowledged_ids'];

    await _db.transaction(() async {
      for (final table in kForeignKeyEntityOrder) {
        final tableSnapshot = outbox.snapshotUpdatedAt[table] ?? const {};
        if (tableSnapshot.isEmpty) continue;

        final Set<String> acknowledgedForTable;
        if (ackRaw is Map<String, dynamic> && ackRaw[table] is List) {
          acknowledgedForTable = (ackRaw[table] as List)
              .map((e) => e.toString())
              .toSet();
        } else if (ackRaw is List) {
          acknowledgedForTable = ackRaw.map((e) => e.toString()).toSet();
        } else {
          // If server returned 2xx without explicit subset filtering, acknowledge sent IDs
          acknowledgedForTable = tableSnapshot.keys.toSet();
        }

        for (final entry in tableSnapshot.entries) {
          if (!acknowledgedForTable.contains(entry.key)) continue;
          await _markRecordSyncedIfUnchanged(
            tableName: table,
            id: entry.key,
            expectedUpdatedAt: entry.value,
          );
        }
      }
    });
  }

  Future<void> _markRecordSyncedIfUnchanged({
    required String tableName,
    required String id,
    required DateTime expectedUpdatedAt,
  }) async {
    switch (tableName) {
      case 'app_settings':
        await (_db.update(_db.appSettings)
              ..where(
                (t) =>
                    t.id.equals(id) & t.updatedAt.equals(expectedUpdatedAt),
              ))
            .write(
          const AppSettingsCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      case 'gym_locations':
        await (_db.update(_db.gymLocations)
              ..where(
                (t) =>
                    t.id.equals(id) & t.updatedAt.equals(expectedUpdatedAt),
              ))
            .write(
          const GymLocationsCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      case 'exercises':
        await (_db.update(_db.exercises)
              ..where(
                (t) =>
                    t.id.equals(id) & t.updatedAt.equals(expectedUpdatedAt),
              ))
            .write(
          const ExercisesCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      case 'gym_machines':
        await (_db.update(_db.gymMachines)
              ..where(
                (t) =>
                    t.id.equals(id) & t.updatedAt.equals(expectedUpdatedAt),
              ))
            .write(
          const GymMachinesCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      case 'exercise_media':
        await (_db.update(_db.exerciseMedia)
              ..where(
                (t) =>
                    t.id.equals(id) & t.updatedAt.equals(expectedUpdatedAt),
              ))
            .write(
          const ExerciseMediaCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      case 'workout_plans':
        await (_db.update(_db.workoutPlans)
              ..where(
                (t) =>
                    t.id.equals(id) & t.updatedAt.equals(expectedUpdatedAt),
              ))
            .write(
          const WorkoutPlansCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      case 'workout_plan_exercises':
        await (_db.update(_db.workoutPlanExercises)
              ..where(
                (t) =>
                    t.id.equals(id) & t.updatedAt.equals(expectedUpdatedAt),
              ))
            .write(
          const WorkoutPlanExercisesCompanion(
            syncStatus: Value(SyncStatus.synced),
          ),
        );
      case 'workout_sessions':
        await (_db.update(_db.workoutSessions)
              ..where(
                (t) =>
                    t.id.equals(id) & t.updatedAt.equals(expectedUpdatedAt),
              ))
            .write(
          const WorkoutSessionsCompanion(syncStatus: Value(SyncStatus.synced)),
        );
      case 'workout_session_exercises':
        await (_db.update(_db.workoutSessionExercises)
              ..where(
                (t) =>
                    t.id.equals(id) & t.updatedAt.equals(expectedUpdatedAt),
              ))
            .write(
          const WorkoutSessionExercisesCompanion(
            syncStatus: Value(SyncStatus.synced),
          ),
        );
      case 'workout_sets':
        await (_db.update(_db.workoutSets)
              ..where(
                (t) =>
                    t.id.equals(id) & t.updatedAt.equals(expectedUpdatedAt),
              ))
            .write(
          const WorkoutSetsCompanion(syncStatus: Value(SyncStatus.synced)),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // PHASE C: DELTA PULL & LAST-WRITE-WINS UPSERT
  // ---------------------------------------------------------------------------

  /// Pulls remote delta changes from `GET /api/v1/sync/pull?since={lastSyncTimestamp}`
  /// and applies them in a single Drift transaction in strict Foreign Key Order (1..10).
  Future<DateTime> pullRemoteChanges({
    required String apiBaseUrl,
    required DateTime? lastSyncTimestamp,
  }) async {
    final sinceParam =
        (lastSyncTimestamp ?? DateTime.utc(1970, 1, 1)).toIso8601String();

    final response = await _dio.get<Map<String, dynamic>>(
      '$apiBaseUrl/api/v1/sync/pull',
      queryParameters: {'since': sinceParam},
    );

    final body = response.data ?? const <String, dynamic>{};
    final changes =
        (body['changes'] as Map<String, dynamic>?) ?? body;
    final rawServerTimestamp =
        (body['server_timestamp'] ?? body['serverTimestamp']) as String?;
    final serverTimestamp = rawServerTimestamp != null
        ? (DateTime.tryParse(rawServerTimestamp)?.toUtc() ??
            DateTime.now().toUtc())
        : DateTime.now().toUtc();

    final mediaFilesToDelete = <({String localPath, String? thumbPath})>[];

    await _db.transaction(() async {
      for (final table in kForeignKeyEntityOrder) {
        final rawList = changes[table];
        if (rawList is! List) continue;

        for (final rawItem in rawList) {
          if (rawItem is! Map<String, dynamic>) continue;
          await _applyRemoteRecordLww(
            tableName: table,
            json: rawItem,
            mediaFilesToDelete: mediaFilesToDelete,
          );
        }
      }
    });

    for (final filePair in mediaFilesToDelete) {
      await _mediaCompressionService.deleteLocalMediaFile(
        localPath: filePair.localPath,
        thumbnailLocalPath: filePair.thumbPath,
      );
    }

    await _preferencesService.setLastSyncTimestamp(serverTimestamp);
    return serverTimestamp;
  }

  Future<void> _applyRemoteRecordLww({
    required String tableName,
    required Map<String, dynamic> json,
    required List<({String localPath, String? thumbPath})> mediaFilesToDelete,
  }) async {
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) return;

    final remoteUpdatedAt = _parseDateTimeUtc(
          json['updated_at'] ?? json['updatedAt'],
        ) ??
        DateTime.now().toUtc();
    final remoteCreatedAt = _parseDateTimeUtc(
          json['created_at'] ?? json['createdAt'],
        ) ??
        remoteUpdatedAt;
    final remoteDeletedAt = _parseDateTimeUtc(
      json['deleted_at'] ?? json['deletedAt'],
    );

    switch (tableName) {
      case 'app_settings':
        final local = await (_db.select(_db.appSettings)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (local != null &&
            !shouldAcceptRemoteByLastWriteWins(
              localSyncStatus: local.syncStatus,
              localUpdatedAt: local.updatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
            )) {
          return;
        }
        await _db.into(_db.appSettings).insertOnConflictUpdate(
              AppSettingsCompanion.insert(
                id: Value(id),
                createdAt: Value(remoteCreatedAt),
                updatedAt: Value(remoteUpdatedAt),
                deletedAt: Value(remoteDeletedAt),
                syncStatus: const Value(SyncStatus.synced),
                useSplitWarmupRest: Value(
                  (json['use_split_warmup_rest'] ??
                          json['useSplitWarmupRest'] ??
                          true)
                      as bool,
                ),
                largeMuscleWarmupRestSeconds: Value(
                  (json['large_muscle_warmup_rest_seconds'] ??
                          json['largeMuscleWarmupRestSeconds'] ??
                          90)
                      as int,
                ),
                smallMuscleWarmupRestSeconds: Value(
                  (json['small_muscle_warmup_rest_seconds'] ??
                          json['smallMuscleWarmupRestSeconds'] ??
                          60)
                      as int,
                ),
                globalWarmupRestSeconds: Value(
                  (json['global_warmup_rest_seconds'] ??
                          json['globalWarmupRestSeconds'] ??
                          60)
                      as int,
                ),
                defaultWorkingSetRestSeconds: Value(
                  (json['default_working_set_rest_seconds'] ??
                          json['defaultWorkingSetRestSeconds'] ??
                          180)
                      as int,
                ),
              ),
            );

      case 'gym_locations':
        final local = await (_db.select(_db.gymLocations)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (local != null &&
            !shouldAcceptRemoteByLastWriteWins(
              localSyncStatus: local.syncStatus,
              localUpdatedAt: local.updatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
            )) {
          return;
        }
        await _db.into(_db.gymLocations).insertOnConflictUpdate(
              GymLocationsCompanion.insert(
                id: Value(id),
                createdAt: Value(remoteCreatedAt),
                updatedAt: Value(remoteUpdatedAt),
                deletedAt: Value(remoteDeletedAt),
                syncStatus: const Value(SyncStatus.synced),
                name: (json['name'] as String?) ?? 'Gym',
                address: Value(json['address'] as String?),
                notes: Value(json['notes'] as String?),
              ),
            );

      case 'exercises':
        final local = await (_db.select(_db.exercises)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (local != null &&
            !shouldAcceptRemoteByLastWriteWins(
              localSyncStatus: local.syncStatus,
              localUpdatedAt: local.updatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
            )) {
          return;
        }
        final eqName = (json['equipment_category'] ??
                json['equipmentCategory'] ??
                'other')
            as String;
        final pmName = (json['primary_muscle_group'] ??
                json['primaryMuscleGroup'] ??
                'chest')
            as String;
        final sizeName = (json['muscle_size_category'] ??
                json['muscleSizeCategory'] ??
                'LARGE')
            as String;
        final typeName = (json['exercise_type'] ??
                json['exerciseType'] ??
                'weight_reps')
            as String;
        final rawSec =
            json['secondary_muscle_groups'] ?? json['secondaryMuscleGroups'];
        final secGroups = <MuscleGroup>[];
        if (rawSec is List) {
          for (final item in rawSec) {
            final match = MuscleGroup.values
                .where((m) => m.name == item.toString())
                .firstOrNull;
            if (match != null) secGroups.add(match);
          }
        }
        await _db.into(_db.exercises).insertOnConflictUpdate(
              ExercisesCompanion.insert(
                id: Value(id),
                createdAt: Value(remoteCreatedAt),
                updatedAt: Value(remoteUpdatedAt),
                deletedAt: Value(remoteDeletedAt),
                syncStatus: const Value(SyncStatus.synced),
                name: (json['name'] as String?) ?? 'Exercise',
                equipmentCategory: EquipmentCategory.values
                        .where((e) => e.name == eqName)
                        .firstOrNull ??
                    EquipmentCategory.other,
                primaryMuscleGroup: MuscleGroup.values
                        .where((m) => m.name == pmName)
                        .firstOrNull ??
                    MuscleGroup.chest,
                secondaryMuscleGroups: Value(secGroups),
                muscleSizeCategory: MuscleSizeCategory.values
                        .where((s) => s.name == sizeName)
                        .firstOrNull ??
                    MuscleSizeCategory.LARGE,
                exerciseType: ExerciseType.values
                        .where((t) => t.name == typeName)
                        .firstOrNull ??
                    ExerciseType.weight_reps,
                defaultWorkingRestSeconds: Value(
                  (json['default_working_rest_seconds'] ??
                          json['defaultWorkingRestSeconds'])
                      as int?,
                ),
                isCustom: Value(
                  (json['is_custom'] ?? json['isCustom'] ?? true) as bool,
                ),
              ),
            );

      case 'gym_machines':
        final local = await (_db.select(_db.gymMachines)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (local != null &&
            !shouldAcceptRemoteByLastWriteWins(
              localSyncStatus: local.syncStatus,
              localUpdatedAt: local.updatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
            )) {
          return;
        }
        final unitName =
            (json['weight_unit'] ?? json['weightUnit'] ?? 'KG') as String;
        await _db.into(_db.gymMachines).insertOnConflictUpdate(
              GymMachinesCompanion.insert(
                id: Value(id),
                createdAt: Value(remoteCreatedAt),
                updatedAt: Value(remoteUpdatedAt),
                deletedAt: Value(remoteDeletedAt),
                syncStatus: const Value(SyncStatus.synced),
                gymLocationId: Value(
                  (json['gym_location_id'] ?? json['gymLocationId']) as String?,
                ),
                exerciseId:
                    (json['exercise_id'] ?? json['exerciseId']) as String,
                brandName: Value(
                  (json['brand_name'] ?? json['brandName']) as String?,
                ),
                weightUnit: Value(
                  WeightUnit.values
                          .where((u) => u.name == unitName)
                          .firstOrNull ??
                      WeightUnit.KG,
                ),
                pinnedNotes: Value(
                  (json['pinned_notes'] ?? json['pinnedNotes']) as String?,
                ),
              ),
            );

      case 'exercise_media':
        final local = await (_db.select(_db.exerciseMedia)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (local != null &&
            !shouldAcceptRemoteByLastWriteWins(
              localSyncStatus: local.syncStatus,
              localUpdatedAt: local.updatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
            )) {
          return;
        }
        if (remoteDeletedAt != null && local != null) {
          mediaFilesToDelete.add((
            localPath: local.localPath,
            thumbPath: local.thumbnailLocalPath,
          ));
        }
        final mediaTypeName =
            (json['media_type'] ?? json['mediaType'] ?? 'photo') as String;
        await _db.into(_db.exerciseMedia).insertOnConflictUpdate(
              ExerciseMediaCompanion.insert(
                id: Value(id),
                createdAt: Value(remoteCreatedAt),
                updatedAt: Value(remoteUpdatedAt),
                deletedAt: Value(remoteDeletedAt),
                syncStatus: const Value(SyncStatus.synced),
                exerciseId:
                    (json['exercise_id'] ?? json['exerciseId']) as String,
                mediaType: MediaType.values
                        .where((m) => m.name == mediaTypeName)
                        .firstOrNull ??
                    MediaType.photo,
                sortOrder: Value(
                  (json['sort_order'] ?? json['sortOrder'] ?? 0) as int,
                ),
                localPath: local?.localPath ??
                    ((json['local_path'] ?? json['localPath'] ?? '') as String),
                thumbnailLocalPath: Value(
                  local?.thumbnailLocalPath ??
                      ((json['thumbnail_local_path'] ??
                              json['thumbnailLocalPath'])
                          as String?),
                ),
                fileSizeBytes:
                    (json['file_size_bytes'] ?? json['fileSizeBytes'] ?? 0)
                        as int,
                durationSeconds: Value(
                  (json['duration_seconds'] ?? json['durationSeconds']) as int?,
                ),
                remoteUrl: Value(
                  (json['remote_url'] ?? json['remoteUrl']) as String?,
                ),
                thumbnailRemoteUrl: Value(
                  (json['thumbnail_remote_url'] ??
                          json['thumbnailRemoteUrl'])
                      as String?,
                ),
                mediaSyncStatus: const Value(MediaSyncStatus.uploaded),
              ),
            );

      case 'workout_plans':
        final local = await (_db.select(_db.workoutPlans)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (local != null &&
            !shouldAcceptRemoteByLastWriteWins(
              localSyncStatus: local.syncStatus,
              localUpdatedAt: local.updatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
            )) {
          return;
        }
        await _db.into(_db.workoutPlans).insertOnConflictUpdate(
              WorkoutPlansCompanion.insert(
                id: Value(id),
                createdAt: Value(remoteCreatedAt),
                updatedAt: Value(remoteUpdatedAt),
                deletedAt: Value(remoteDeletedAt),
                syncStatus: const Value(SyncStatus.synced),
                name: (json['name'] as String?) ?? 'Plan',
                notes: Value(json['notes'] as String?),
              ),
            );

      case 'workout_plan_exercises':
        final local = await (_db.select(_db.workoutPlanExercises)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (local != null &&
            !shouldAcceptRemoteByLastWriteWins(
              localSyncStatus: local.syncStatus,
              localUpdatedAt: local.updatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
            )) {
          return;
        }
        await _db.into(_db.workoutPlanExercises).insertOnConflictUpdate(
              WorkoutPlanExercisesCompanion.insert(
                id: Value(id),
                createdAt: Value(remoteCreatedAt),
                updatedAt: Value(remoteUpdatedAt),
                deletedAt: Value(remoteDeletedAt),
                syncStatus: const Value(SyncStatus.synced),
                workoutPlanId: (json['workout_plan_id'] ??
                    json['workoutPlanId']) as String,
                exerciseId:
                    (json['exercise_id'] ?? json['exerciseId']) as String,
                defaultGymMachineId: Value(
                  (json['default_gym_machine_id'] ??
                          json['defaultGymMachineId'])
                      as String?,
                ),
                sortOrder:
                    (json['sort_order'] ?? json['sortOrder'] ?? 0) as int,
                supersetGroupId: Value(
                  (json['superset_group_id'] ?? json['supersetGroupId'])
                      as String?,
                ),
                targetSets: Value(
                  (json['target_sets'] ?? json['targetSets'] ?? 3) as int,
                ),
                targetReps: Value(
                  (json['target_reps'] ?? json['targetReps']) as int?,
                ),
                targetRestSeconds: Value(
                  (json['target_rest_seconds'] ?? json['targetRestSeconds'])
                      as int?,
                ),
              ),
            );

      case 'workout_sessions':
        final local = await (_db.select(_db.workoutSessions)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        // Protect active in-progress local session
        if (local != null && local.completedAt == null && local.deletedAt == null) {
          return;
        }
        if (local != null &&
            !shouldAcceptRemoteByLastWriteWins(
              localSyncStatus: local.syncStatus,
              localUpdatedAt: local.updatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
            )) {
          return;
        }
        final startedAt = _parseDateTimeUtc(
              json['started_at'] ?? json['startedAt'],
            ) ??
            remoteCreatedAt;
        final completedAt = _parseDateTimeUtc(
          json['completed_at'] ?? json['completedAt'],
        );
        await _db.into(_db.workoutSessions).insertOnConflictUpdate(
              WorkoutSessionsCompanion.insert(
                id: Value(id),
                createdAt: Value(remoteCreatedAt),
                updatedAt: Value(remoteUpdatedAt),
                deletedAt: Value(remoteDeletedAt),
                syncStatus: const Value(SyncStatus.synced),
                workoutPlanId: Value(
                  (json['workout_plan_id'] ?? json['workoutPlanId']) as String?,
                ),
                gymLocationId: Value(
                  (json['gym_location_id'] ?? json['gymLocationId']) as String?,
                ),
                startedAt: startedAt,
                completedAt: Value(completedAt),
                sessionNotes: Value(
                  (json['session_notes'] ?? json['sessionNotes']) as String?,
                ),
              ),
            );

      case 'workout_session_exercises':
        final local = await (_db.select(_db.workoutSessionExercises)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (local != null &&
            !shouldAcceptRemoteByLastWriteWins(
              localSyncStatus: local.syncStatus,
              localUpdatedAt: local.updatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
            )) {
          return;
        }
        await _db.into(_db.workoutSessionExercises).insertOnConflictUpdate(
              WorkoutSessionExercisesCompanion.insert(
                id: Value(id),
                createdAt: Value(remoteCreatedAt),
                updatedAt: Value(remoteUpdatedAt),
                deletedAt: Value(remoteDeletedAt),
                syncStatus: const Value(SyncStatus.synced),
                workoutSessionId: (json['workout_session_id'] ??
                    json['workoutSessionId']) as String,
                exerciseId:
                    (json['exercise_id'] ?? json['exerciseId']) as String,
                gymMachineId: Value(
                  (json['gym_machine_id'] ?? json['gymMachineId']) as String?,
                ),
                sortOrder: Value(
                  (json['sort_order'] ?? json['sortOrder'] ?? 0) as int,
                ),
                supersetGroupId: Value(
                  (json['superset_group_id'] ?? json['supersetGroupId'])
                      as String?,
                ),
              ),
            );

      case 'workout_sets':
        final local = await (_db.select(_db.workoutSets)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (local != null &&
            !shouldAcceptRemoteByLastWriteWins(
              localSyncStatus: local.syncStatus,
              localUpdatedAt: local.updatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
            )) {
          return;
        }
        final setTypeName =
            (json['set_type'] ?? json['setType'] ?? 'normal') as String;
        final assistName =
            (json['assistance_type'] ?? json['assistanceType'] ?? 'solo')
                as String;
        await _db.into(_db.workoutSets).insertOnConflictUpdate(
              WorkoutSetsCompanion.insert(
                id: Value(id),
                createdAt: Value(remoteCreatedAt),
                updatedAt: Value(remoteUpdatedAt),
                deletedAt: Value(remoteDeletedAt),
                syncStatus: const Value(SyncStatus.synced),
                workoutSessionExerciseId:
                    (json['workout_session_exercise_id'] ??
                        json['workoutSessionExerciseId']) as String,
                setNumber:
                    (json['set_number'] ?? json['setNumber'] ?? 1) as int,
                parentSetId: Value(
                  (json['parent_set_id'] ?? json['parentSetId']) as String?,
                ),
                setType: Value(
                  SetType.values
                          .where((s) => s.name == setTypeName)
                          .firstOrNull ??
                      SetType.normal,
                ),
                weight: Value((json['weight'] as num?)?.toDouble()),
                reps: Value(json['reps'] as int?),
                durationSeconds: Value(
                  (json['duration_seconds'] ?? json['durationSeconds']) as int?,
                ),
                distanceMeters: Value(
                  ((json['distance_meters'] ?? json['distanceMeters']) as num?)
                      ?.toDouble(),
                ),
                rpe: Value((json['rpe'] as num?)?.toDouble()),
                assistanceType: Value(
                  AssistanceType.values
                          .where((a) => a.name == assistName)
                          .firstOrNull ??
                      AssistanceType.solo,
                ),
                targetRestSeconds: Value(
                  (json['target_rest_seconds'] ?? json['targetRestSeconds'])
                      as int?,
                ),
                actualRestSeconds: Value(
                  (json['actual_rest_seconds'] ?? json['actualRestSeconds'])
                      as int?,
                ),
                isCompleted: Value(
                  (json['is_completed'] ?? json['isCompleted'] ?? false)
                      as bool,
                ),
                completedAt: Value(
                  _parseDateTimeUtc(
                    json['completed_at'] ?? json['completedAt'],
                  ),
                ),
              ),
            );
    }
  }

  DateTime? _parseDateTimeUtc(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw.toUtc();
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw)?.toUtc();
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // ENTITY JSON SERIALIZERS (SNAKE_CASE ISO-8601 UTC)
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _serializeAppSetting(AppSetting r) => {
        'id': r.id,
        'created_at': r.createdAt.toUtc().toIso8601String(),
        'updated_at': r.updatedAt.toUtc().toIso8601String(),
        'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
        'use_split_warmup_rest': r.useSplitWarmupRest,
        'large_muscle_warmup_rest_seconds': r.largeMuscleWarmupRestSeconds,
        'small_muscle_warmup_rest_seconds': r.smallMuscleWarmupRestSeconds,
        'global_warmup_rest_seconds': r.globalWarmupRestSeconds,
        'default_working_set_rest_seconds': r.defaultWorkingSetRestSeconds,
      };

  Map<String, dynamic> _serializeGymLocation(GymLocation r) => {
        'id': r.id,
        'created_at': r.createdAt.toUtc().toIso8601String(),
        'updated_at': r.updatedAt.toUtc().toIso8601String(),
        'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
        'name': r.name,
        'address': r.address,
        'notes': r.notes,
      };

  Map<String, dynamic> _serializeExercise(Exercise r) => {
        'id': r.id,
        'created_at': r.createdAt.toUtc().toIso8601String(),
        'updated_at': r.updatedAt.toUtc().toIso8601String(),
        'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
        'name': r.name,
        'equipment_category': r.equipmentCategory.name,
        'primary_muscle_group': r.primaryMuscleGroup.name,
        'secondary_muscle_groups':
            r.secondaryMuscleGroups.map((m) => m.name).toList(growable: false),
        'muscle_size_category': r.muscleSizeCategory.name,
        'exercise_type': r.exerciseType.name,
        'default_working_rest_seconds': r.defaultWorkingRestSeconds,
        'is_custom': r.isCustom,
      };

  Map<String, dynamic> _serializeGymMachine(GymMachine r) => {
        'id': r.id,
        'created_at': r.createdAt.toUtc().toIso8601String(),
        'updated_at': r.updatedAt.toUtc().toIso8601String(),
        'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
        'gym_location_id': r.gymLocationId,
        'exercise_id': r.exerciseId,
        'brand_name': r.brandName,
        'weight_unit': r.weightUnit.name,
        'pinned_notes': r.pinnedNotes,
      };

  Map<String, dynamic> _serializeExerciseMedia(ExerciseMediaData r) => {
        'id': r.id,
        'created_at': r.createdAt.toUtc().toIso8601String(),
        'updated_at': r.updatedAt.toUtc().toIso8601String(),
        'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
        'exercise_id': r.exerciseId,
        'media_type': r.mediaType.name,
        'sort_order': r.sortOrder,
        'file_size_bytes': r.fileSizeBytes,
        'duration_seconds': r.durationSeconds,
        'remote_url': r.remoteUrl,
        'thumbnail_remote_url': r.thumbnailRemoteUrl,
        'media_sync_status': r.mediaSyncStatus.name,
      };

  Map<String, dynamic> _serializeWorkoutPlan(WorkoutPlan r) => {
        'id': r.id,
        'created_at': r.createdAt.toUtc().toIso8601String(),
        'updated_at': r.updatedAt.toUtc().toIso8601String(),
        'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
        'name': r.name,
        'notes': r.notes,
      };

  Map<String, dynamic> _serializeWorkoutPlanExercise(WorkoutPlanExercise r) => {
        'id': r.id,
        'created_at': r.createdAt.toUtc().toIso8601String(),
        'updated_at': r.updatedAt.toUtc().toIso8601String(),
        'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
        'workout_plan_id': r.workoutPlanId,
        'exercise_id': r.exerciseId,
        'default_gym_machine_id': r.defaultGymMachineId,
        'sort_order': r.sortOrder,
        'superset_group_id': r.supersetGroupId,
        'target_sets': r.targetSets,
        'target_reps': r.targetReps,
        'target_rest_seconds': r.targetRestSeconds,
      };

  Map<String, dynamic> _serializeWorkoutSession(WorkoutSession r) => {
        'id': r.id,
        'created_at': r.createdAt.toUtc().toIso8601String(),
        'updated_at': r.updatedAt.toUtc().toIso8601String(),
        'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
        'workout_plan_id': r.workoutPlanId,
        'gym_location_id': r.gymLocationId,
        'started_at': r.startedAt.toUtc().toIso8601String(),
        'completed_at': r.completedAt?.toUtc().toIso8601String(),
        'session_notes': r.sessionNotes,
      };

  Map<String, dynamic> _serializeWorkoutSessionExercise(
    WorkoutSessionExercise r,
  ) =>
      {
        'id': r.id,
        'created_at': r.createdAt.toUtc().toIso8601String(),
        'updated_at': r.updatedAt.toUtc().toIso8601String(),
        'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
        'workout_session_id': r.workoutSessionId,
        'exercise_id': r.exerciseId,
        'gym_machine_id': r.gymMachineId,
        'sort_order': r.sortOrder,
        'superset_group_id': r.supersetGroupId,
      };

  Map<String, dynamic> _serializeWorkoutSet(WorkoutSet r) => {
        'id': r.id,
        'created_at': r.createdAt.toUtc().toIso8601String(),
        'updated_at': r.updatedAt.toUtc().toIso8601String(),
        'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
        'workout_session_exercise_id': r.workoutSessionExerciseId,
        'set_number': r.setNumber,
        'parent_set_id': r.parentSetId,
        'set_type': r.setType.name,
        'weight': r.weight,
        'reps': r.reps,
        'duration_seconds': r.durationSeconds,
        'distance_meters': r.distanceMeters,
        'rpe': r.rpe,
        'assistance_type': r.assistanceType.name,
        'target_rest_seconds': r.targetRestSeconds,
        'actual_rest_seconds': r.actualRestSeconds,
        'is_completed': r.isCompleted,
        'completed_at': r.completedAt?.toUtc().toIso8601String(),
      };
}

@Riverpod(keepAlive: true)
SyncEngine syncEngine(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final mediaSync = ref.watch(mediaSyncServiceProvider);
  final mediaCompression = ref.watch(mediaCompressionServiceProvider);
  final prefs = ref.watch(syncPreferencesServiceProvider);
  return SyncEngine(
    db: db,
    mediaSyncService: mediaSync,
    mediaCompressionService: mediaCompression,
    preferencesService: prefs,
  );
}

final pendingOutboxCountStreamProvider = StreamProvider.autoDispose<int>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.watchPendingOutboxCount();
});

/// Riverpod controller managing [SyncEngineState], auto-sync on app startup,
/// auto-sync when connectivity recovers (`none` -> `wifi`/`mobile`), and manual sync.
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _wasOffline = false;

  @override
  SyncEngineState build() {
    ref.onDispose(() {
      _connectivitySub?.cancel();
    });
    _initializeAndAttachAutoTriggers();
    return const SyncEngineState();
  }

  Future<void> _initializeAndAttachAutoTriggers() async {
    final prefs = ref.read(syncPreferencesServiceProvider);
    final config = await prefs.getConfig();

    bool isCurrentlyOnline = true;
    try {
      final results = await Connectivity().checkConnectivity();
      isCurrentlyOnline =
          !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    } catch (_) {
      isCurrentlyOnline = true;
    }

    _wasOffline = !isCurrentlyOnline;
    state = state.copyWith(
      isOnline: isCurrentlyOnline,
      apiBaseUrl: config.apiBaseUrl,
      authToken: config.authToken,
      lastSyncedAt: () => config.lastSyncTimestamp,
      phase: isCurrentlyOnline
          ? (config.lastSyncTimestamp != null
              ? CloudSyncPhase.synced
              : CloudSyncPhase.idle)
          : CloudSyncPhase.offline,
    );

    // Trigger 1: Auto-sync on app startup if online & configured
    if (isCurrentlyOnline && config.isConfigured) {
      unawaited(triggerSyncNow(silentIfUnconfigured: true));
    }

    // Trigger 2: Auto-sync when internet connectivity recovers (none -> wifi/mobile)
    try {
      _connectivitySub =
          Connectivity().onConnectivityChanged.listen((results) {
        final nowOnline =
            !results.contains(ConnectivityResult.none) && results.isNotEmpty;
        final transitionedOnline = _wasOffline && nowOnline;
        _wasOffline = !nowOnline;

        state = state.copyWith(
          isOnline: nowOnline,
          phase: nowOnline ? state.phase : CloudSyncPhase.offline,
        );

        if (transitionedOnline && state.isConfigured) {
          unawaited(triggerSyncNow(silentIfUnconfigured: true));
        }
      });
    } catch (_) {
      // Ignore connectivity listener errors in test environments.
    }
  }

  /// Updates the self-hosted Backend URL and Bearer Token / API Key.
  Future<void> updateEndpointConfig({
    required String apiBaseUrl,
    required String authToken,
  }) async {
    final prefs = ref.read(syncPreferencesServiceProvider);
    await prefs.saveEndpointConfig(
      apiBaseUrl: apiBaseUrl,
      authToken: authToken,
    );
    final updated = await prefs.getConfig();
    state = state.copyWith(
      apiBaseUrl: updated.apiBaseUrl,
      authToken: updated.authToken,
      errorMessage: () => null,
    );
  }

  /// Triggers a non-blocking background synchronization run (`SyncEngine.syncAll()`).
  Future<void> triggerSyncNow({bool silentIfUnconfigured = false}) async {
    final engine = ref.read(syncEngineProvider);
    if (engine.isSyncing) return;

    final prefs = ref.read(syncPreferencesServiceProvider);
    final config = await prefs.getConfig();

    if (!config.isConfigured) {
      if (!silentIfUnconfigured) {
        state = state.copyWith(
          phase: CloudSyncPhase.error,
          errorMessage: () =>
              'Backend URL belum diatur. Isi URL server Cloud Sync terlebih dahulu.',
        );
      }
      return;
    }

    if (!state.isOnline) {
      state = state.copyWith(
        phase: CloudSyncPhase.offline,
        errorMessage: () => 'Perangkat sedang offline. Perubahan disimpan di antrean lokal.',
      );
      return;
    }

    state = state.copyWith(
      isSyncing: true,
      phase: CloudSyncPhase.uploadingMedia,
      errorMessage: () => null,
    );

    try {
      final newSyncedAt = await engine.syncAll(
        onPhaseChanged: (phase) {
          state = state.copyWith(phase: phase);
        },
      );

      state = state.copyWith(
        isSyncing: false,
        phase: CloudSyncPhase.synced,
        lastSyncedAt: () => newSyncedAt ?? DateTime.now().toUtc(),
        errorMessage: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        phase: CloudSyncPhase.error,
        errorMessage: () => 'Sync gagal: $e',
      );
    }
  }
}
