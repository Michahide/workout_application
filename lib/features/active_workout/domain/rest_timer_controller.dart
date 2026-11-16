import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/database/tables.dart';
import '../../settings/data/app_settings_repository.dart';
import '../data/active_workout_repository.dart';

part 'rest_timer_controller.g.dart';

/// Immutable state for the timestamp-based Smart Rest Timer.
///
/// All time calculations (`elapsedSeconds`, `remainingSeconds`, `isOvertime`)
/// are derived strictly from UTC wall-clock timestamps (`lastSetCompletedAt`
/// and `targetEndTime`), ensuring 100% accuracy even when the app is minimized
/// or the phone screen is locked.
class RestTimerState {
  const RestTimerState({
    this.isRunning = false,
    this.lastSetCompletedAt,
    this.targetRestSeconds = 0,
    this.targetEndTime,
    this.exerciseName,
    this.nextSupersetExerciseId,
    this.nextSupersetBanner,
    this.tick = 0,
  });

  final bool isRunning;
  final DateTime? lastSetCompletedAt;
  final int targetRestSeconds;
  final DateTime? targetEndTime;
  final String? exerciseName;

  /// When the user completes Set 1 of Superset A1, points to Exercise A2 so UI
  /// can highlight/scroll to A2 before starting the full round rest.
  final String? nextSupersetExerciseId;
  final String? nextSupersetBanner;

  /// Monotonic counter used solely to trigger 1Hz UI refreshes while active.
  final int tick;

  /// Real elapsed seconds since the previous set was completed.
  int get elapsedSeconds {
    final start = lastSetCompletedAt;
    if (start == null) return 0;
    return DateTime.now().toUtc().difference(start).inSeconds.clamp(0, 86400);
  }

  /// Remaining seconds until `targetEndTime`. Negative values indicate overtime.
  int get remainingSeconds {
    final end = targetEndTime;
    if (end == null) return 0;
    return end.difference(DateTime.now().toUtc()).inSeconds;
  }

  /// True when the user has rested longer than `targetRestSeconds`.
  bool get isOvertime => isRunning && remainingSeconds < 0;

  /// Progress from `0.0` to `1.0` toward `targetRestSeconds`.
  double get progress {
    if (!isRunning || targetRestSeconds <= 0) return 0.0;
    return (elapsedSeconds / targetRestSeconds).clamp(0.0, 1.0);
  }

  RestTimerState copyWith({
    bool? isRunning,
    DateTime? Function()? lastSetCompletedAt,
    int? targetRestSeconds,
    DateTime? Function()? targetEndTime,
    String? Function()? exerciseName,
    String? Function()? nextSupersetExerciseId,
    String? Function()? nextSupersetBanner,
    int? tick,
  }) {
    return RestTimerState(
      isRunning: isRunning ?? this.isRunning,
      lastSetCompletedAt: lastSetCompletedAt != null
          ? lastSetCompletedAt()
          : this.lastSetCompletedAt,
      targetRestSeconds: targetRestSeconds ?? this.targetRestSeconds,
      targetEndTime:
          targetEndTime != null ? targetEndTime() : this.targetEndTime,
      exerciseName: exerciseName != null ? exerciseName() : this.exerciseName,
      nextSupersetExerciseId: nextSupersetExerciseId != null
          ? nextSupersetExerciseId()
          : this.nextSupersetExerciseId,
      nextSupersetBanner: nextSupersetBanner != null
          ? nextSupersetBanner()
          : this.nextSupersetBanner,
      tick: tick ?? this.tick,
    );
  }
}

@Riverpod(keepAlive: true)
class RestTimerController extends _$RestTimerController {
  static const int _kRestNotificationId = 9001;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _notificationsInitialized = false;
  Timer? _uiRefreshTimer;

  @override
  RestTimerState build() {
    ref.onDispose(() {
      _uiRefreshTimer?.cancel();
    });
    _ensureNotificationsInitialized();
    return const RestTimerState();
  }

  Future<void> _ensureNotificationsInitialized() async {
    if (_notificationsInitialized) return;
    try {
      tz_data.initializeTimeZones();
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(
          defaultActionName: 'Open notification',
        ),
      );
      await _notificationsPlugin.initialize(settings: initializationSettings);
      _notificationsInitialized = true;
    } catch (_) {
      // Gracefully ignore in environments where notifications are unsupported.
    }
  }

  void _startUiRefreshTicker() {
    _uiRefreshTimer?.cancel();
    _uiRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isRunning || state.lastSetCompletedAt != null) {
        state = state.copyWith(tick: state.tick + 1);
      }
    });
  }

  /// Computes the actual rest seconds elapsed since the previous set was completed.
  /// Returns `null` if there was no prior set completed in this session.
  int? computeActualRestSeconds() {
    final prevCompletedAt = state.lastSetCompletedAt;
    if (prevCompletedAt == null) return null;
    return DateTime.now()
        .toUtc()
        .difference(prevCompletedAt)
        .inSeconds
        .clamp(0, 7200);
  }

  /// Called when the user marks a set as completed (`isCompleted == true`).
  ///
  /// 1. Records `lastSetCompletedAt = DateTime.now().toUtc()`.
  /// 2. Checks **Superset Rules**: if the exercise belongs to a `supersetGroupId`
  ///    and another exercise in the same superset still has its corresponding set
  ///    incomplete, sets `nextSupersetExerciseId` and `nextSupersetBanner` to
  ///    guide the lifter to the next superset movement before starting the full
  ///    round rest timer.
  /// 3. Resolves `targetRestSeconds` from `AppSettings` (split warm-up `LARGE` vs
  ///    `SMALL`, global warm-up, or working set rest) and schedules a local
  ///    notification at `targetEndTime`.
  Future<int> onSetCompleted({
    required ActiveWorkoutSessionDetails sessionDetails,
    required ActiveSessionExerciseBundle currentExerciseBundle,
    required int completedSetNumber,
    required SetType completedSetType,
    int? customSetTargetRestSeconds,
  }) async {
    final now = DateTime.now().toUtc();
    final settings = await ref.read(appSettingsRepositoryProvider).getSettings();

    final resolvedTargetRest = AppSettingsRepository.resolveTargetRestSeconds(
      settings: settings,
      setType: completedSetType,
      muscleSizeCategory: currentExerciseBundle.exercise.muscleSizeCategory,
      customWorkingRestSeconds: customSetTargetRestSeconds ??
          currentExerciseBundle.exercise.defaultWorkingRestSeconds,
    );

    // Check Superset group progression
    final supersetGroupId =
        currentExerciseBundle.sessionExercise.supersetGroupId;
    if (supersetGroupId != null && supersetGroupId.isNotEmpty) {
      final groupMembers = sessionDetails.exercises
          .where((e) => e.sessionExercise.supersetGroupId == supersetGroupId)
          .toList(growable: false);

      if (groupMembers.length >= 2) {
        final currentIndex = groupMembers.indexWhere(
          (e) =>
              e.sessionExercise.id == currentExerciseBundle.sessionExercise.id,
        );

        // Look for the next member in the superset that hasn't completed this setNumber yet
        for (var offset = 1; offset < groupMembers.length; offset++) {
          final candidate =
              groupMembers[(currentIndex + offset) % groupMembers.length];
          final matchingSet = candidate.sets
              .where((s) => s.setNumber == completedSetNumber)
              .firstOrNull;
          if (matchingSet != null && !matchingSet.isCompleted) {
            await _cancelScheduledNotification();
            state = RestTimerState(
              isRunning: false,
              lastSetCompletedAt: now,
              targetRestSeconds: resolvedTargetRest,
              targetEndTime: null,
              exerciseName: candidate.exercise.name,
              nextSupersetExerciseId: candidate.sessionExercise.id,
              nextSupersetBanner:
                  'Lanjut Superset ${candidate.supersetBadge ?? ""}: '
                  '${candidate.exercise.name} (Set $completedSetNumber)',
              tick: state.tick + 1,
            );
            _startUiRefreshTicker();
            return resolvedTargetRest;
          }
        }
      }
    }

    // Standard set or final exercise in a superset round -> start main Rest Timer
    final endTime = now.add(Duration(seconds: resolvedTargetRest));
    state = RestTimerState(
      isRunning: true,
      lastSetCompletedAt: now,
      targetRestSeconds: resolvedTargetRest,
      targetEndTime: endTime,
      exerciseName: currentExerciseBundle.exercise.name,
      nextSupersetExerciseId: null,
      nextSupersetBanner: null,
      tick: state.tick + 1,
    );

    _startUiRefreshTicker();
    await _scheduleRestFinishedNotification(
      targetEndTime: endTime,
      exerciseName: currentExerciseBundle.exercise.name,
    );

    return resolvedTargetRest;
  }

  /// Adjusts the active target rest duration by [deltaSeconds] (e.g. `+15` or `-15`).
  Future<void> adjustTargetRest(int deltaSeconds) async {
    final start = state.lastSetCompletedAt;
    if (!state.isRunning || start == null) return;

    final updatedTarget = (state.targetRestSeconds + deltaSeconds).clamp(5, 900);
    final updatedEnd = start.add(Duration(seconds: updatedTarget));

    state = state.copyWith(
      targetRestSeconds: updatedTarget,
      targetEndTime: () => updatedEnd,
      tick: state.tick + 1,
    );

    if (updatedEnd.isAfter(DateTime.now().toUtc())) {
      await _scheduleRestFinishedNotification(
        targetEndTime: updatedEnd,
        exerciseName: state.exerciseName ?? 'Latihan',
      );
    } else {
      await _cancelScheduledNotification();
    }
  }

  /// Dismisses the countdown bar and cancels any pending notification while
  /// preserving `lastSetCompletedAt` so `actualRestSeconds` is still recorded
  /// when Set N+1 is completed.
  Future<void> skipTimer() async {
    await _cancelScheduledNotification();
    state = state.copyWith(
      isRunning: false,
      targetEndTime: () => null,
      nextSupersetBanner: () => null,
      nextSupersetExerciseId: () => null,
      tick: state.tick + 1,
    );
  }

  /// Resets the timer completely when a workout session finishes or is discarded.
  Future<void> resetAll() async {
    _uiRefreshTimer?.cancel();
    await _cancelScheduledNotification();
    state = const RestTimerState();
  }

  Future<void> _scheduleRestFinishedNotification({
    required DateTime targetEndTime,
    required String exerciseName,
  }) async {
    await _ensureNotificationsInitialized();
    await _cancelScheduledNotification();

    if (!targetEndTime.isAfter(DateTime.now().toUtc())) return;

    try {
      final scheduledDate = tz.TZDateTime.from(targetEndTime, tz.local);
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'rest_timer_channel',
          'Smart Rest Timer',
          channelDescription: 'Notifikasi saat waktu istirahat antar set selesai',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.zonedSchedule(
        id: _kRestNotificationId,
        title: 'Waktu Istirahat Selesai! 💪',
        body: 'Saatnya mulai set berikutnya untuk $exerciseName.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // Ignore scheduling errors on desktop/test environments.
    }
  }

  Future<void> _cancelScheduledNotification() async {
    try {
      await _notificationsPlugin.cancel(id: _kRestNotificationId);
    } catch (_) {
      // Ignore cancellation errors on unsupported platforms.
    }
  }
}
