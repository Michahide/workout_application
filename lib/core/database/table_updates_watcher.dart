import 'dart:async';

import 'package:drift/drift.dart';

import 'app_database.dart';

/// Reactive multi-table watcher built on Drift's [AppDatabase.tableUpdates].
///
/// Avoids Dart's `Stream.asyncExpand` on infinite `.watch()` streams (which blocks
/// outer stream emissions because the inner stream never closes).
///
/// Whenever any table in [tables] emits a [TableUpdate], [load] is executed
/// (with automatic coalescing if a load is already in flight) and the latest
/// result is emitted to listeners immediately.
Stream<T> watchWithTableUpdates<T>({
  required AppDatabase db,
  required List<TableInfo<Table, dynamic>> tables,
  required Future<T> Function() load,
}) {
  return Stream.multi((controller) {
    var isDisposed = false;
    var isLoading = false;
    var hasPendingReload = false;

    Future<void> triggerLoad() async {
      if (isDisposed) return;
      if (isLoading) {
        hasPendingReload = true;
        return;
      }
      isLoading = true;
      try {
        do {
          hasPendingReload = false;
          final result = await load();
          if (!isDisposed) {
            controller.add(result);
          }
        } while (hasPendingReload && !isDisposed);
      } catch (e, st) {
        if (!isDisposed) {
          controller.addError(e, st);
        }
      } finally {
        isLoading = false;
      }
    }

    final query = tables.isEmpty
        ? const TableUpdateQuery.any()
        : TableUpdateQuery.onAllTables(tables);

    final subscription = db.tableUpdates(query).listen((_) {
      triggerLoad();
    });

    // Load initial snapshot immediately on subscription
    triggerLoad();

    controller.onCancel = () {
      isDisposed = true;
      return subscription.cancel();
    };
  });
}
