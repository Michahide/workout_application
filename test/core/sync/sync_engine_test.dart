import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_application/core/database/app_database.dart';
import 'package:workout_application/core/database/syncable_table_mixin.dart';
import 'package:workout_application/core/media/media_compression_service.dart';
import 'package:workout_application/core/sync/media_sync_service.dart';
import 'package:workout_application/core/sync/sync_engine.dart';
import 'package:workout_application/core/sync/sync_preferences_service.dart';

void main() {
  group('SyncEngine - Last-Write-Wins (LWW) Conflict Resolution', () {
    final baseTime = DateTime.utc(2026, 11, 16, 12, 0, 0);
    final olderTime = baseTime.subtract(const Duration(minutes: 5));
    final newerTime = baseTime.add(const Duration(minutes: 5));

    test(
      'rejects remote record when local is pending_push and remote.updatedAt <= local.updatedAt',
      () {
        expect(
          SyncEngine.shouldAcceptRemoteByLastWriteWins(
            localSyncStatus: SyncStatus.pending_push,
            localUpdatedAt: baseTime,
            remoteUpdatedAt: olderTime,
          ),
          isFalse,
        );

        expect(
          SyncEngine.shouldAcceptRemoteByLastWriteWins(
            localSyncStatus: SyncStatus.pending_push,
            localUpdatedAt: baseTime,
            remoteUpdatedAt: baseTime,
          ),
          isFalse,
        );
      },
    );

    test(
      'accepts remote record when local is pending_push and remote.updatedAt is strictly newer',
      () {
        expect(
          SyncEngine.shouldAcceptRemoteByLastWriteWins(
            localSyncStatus: SyncStatus.pending_push,
            localUpdatedAt: baseTime,
            remoteUpdatedAt: newerTime,
          ),
          isTrue,
        );
      },
    );

    test(
      'accepts remote record when local is already synced and remote.updatedAt >= local.updatedAt',
      () {
        expect(
          SyncEngine.shouldAcceptRemoteByLastWriteWins(
            localSyncStatus: SyncStatus.synced,
            localUpdatedAt: baseTime,
            remoteUpdatedAt: baseTime,
          ),
          isTrue,
        );

        expect(
          SyncEngine.shouldAcceptRemoteByLastWriteWins(
            localSyncStatus: SyncStatus.synced,
            localUpdatedAt: baseTime,
            remoteUpdatedAt: newerTime,
          ),
          isTrue,
        );
      },
    );
  });

  group('SyncEngine - Foreign Key Dependency Serialization Order & Active Session Protection', () {
    test(
      'orderPayloadByForeignKey enforces strict 1..10 parent-to-child key order',
      () {
        final unorderedInput = <String, List<Map<String, dynamic>>>{
          'workout_sets': [
            {'id': 'set-1'},
          ],
          'gym_machines': [
            {'id': 'machine-1'},
          ],
          'gym_locations': [
            {'id': 'gym-1'},
          ],
          'app_settings': [
            {'id': 'settings-1'},
          ],
        };

        final ordered = SyncEngine.orderPayloadByForeignKey(unorderedInput);
        expect(
          ordered.keys.toList(),
          equals(const [
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
          ]),
        );
        expect(ordered['gym_locations']!.single['id'], equals('gym-1'));
        expect(ordered['workout_sets']!.single['id'], equals('set-1'));
      },
    );

    test(
      'collectOutboxBatch serializes in FK order and excludes in-progress active workout sessions',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);

        final engine = SyncEngine(
          db: db,
          mediaSyncService: MediaSyncService(db),
          mediaCompressionService: MediaCompressionService(),
          preferencesService: SyncPreferencesService(),
        );

        final now = DateTime.utc(2026, 11, 16, 15, 0);

        // Insert a pending gym location
        await db.into(db.gymLocations).insert(
              GymLocationsCompanion.insert(
                id: const Value('gym-1'),
                name: 'FTL Gym',
                createdAt: Value(now),
                updatedAt: Value(now),
                syncStatus: const Value(SyncStatus.pending_push),
              ),
            );

        // Insert an active (incomplete) session -> MUST be excluded from outbox
        await db.into(db.workoutSessions).insert(
              WorkoutSessionsCompanion.insert(
                id: const Value('session-active'),
                gymLocationId: const Value('gym-1'),
                startedAt: now,
                completedAt: const Value(null),
                createdAt: Value(now),
                updatedAt: Value(now),
                syncStatus: const Value(SyncStatus.pending_push),
              ),
            );

        // Insert a completed session -> MUST be included in outbox
        await db.into(db.workoutSessions).insert(
              WorkoutSessionsCompanion.insert(
                id: const Value('session-completed'),
                gymLocationId: const Value('gym-1'),
                startedAt: now.subtract(const Duration(hours: 1)),
                completedAt: Value(now),
                createdAt: Value(now),
                updatedAt: Value(now),
                syncStatus: const Value(SyncStatus.pending_push),
              ),
            );

        final outbox = await engine.collectOutboxBatch();
        expect(
          outbox.payload.keys.toList(),
          equals(SyncEngine.kForeignKeyEntityOrder),
        );
        expect(
          outbox.payload['gym_locations']!.map((e) => e['id']),
          contains('gym-1'),
        );

        final pushedSessionIds = outbox.payload['workout_sessions']!
            .map((e) => e['id'])
            .toList();
        expect(pushedSessionIds, contains('session-completed'));
        expect(pushedSessionIds, isNot(contains('session-active')));
      },
    );
  });
}
