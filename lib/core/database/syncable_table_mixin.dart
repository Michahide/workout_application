// ignore_for_file: constant_identifier_names

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Synchronization status for offline-first entities.
enum SyncStatus {
  synced,
  pending_push,
  pending_delete;

  /// CamelCase alias for [SyncStatus.pending_push].
  static const SyncStatus pendingPush = SyncStatus.pending_push;

  /// CamelCase alias for [SyncStatus.pending_delete].
  static const SyncStatus pendingDelete = SyncStatus.pending_delete;
}

/// Base Drift table mixin enforcing Offline-First & Cloud-Sync rules:
/// - Client-generated UUID v4 primary key (`id`)
/// - UTC timestamps (`createdAt`, `updatedAt`)
/// - Soft delete timestamp (`deletedAt`)
/// - Cloud sync state (`syncStatus`)
mixin SyncableTableMixin on Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  TextColumn get syncStatus => textEnum<SyncStatus>()
      .withDefault(Constant(SyncStatus.pending_push.name))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
