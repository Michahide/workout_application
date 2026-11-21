import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/database/domain_labels.dart';
import '../../../core/database/tables.dart';
import '../../settings/data/app_settings_repository.dart';
import '../../settings/data/user_preferences_repository.dart';
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
    this.activeSessionExerciseId,
    this.nextSupersetExerciseId,
    this.nextSupersetBanner,
    this.tick = 0,
  });

  final bool isRunning;
  final DateTime? lastSetCompletedAt;
  final int targetRestSeconds;
  final DateTime? targetEndTime;
  final String? exerciseName;
  final String? activeSessionExerciseId;

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
    String? Function()? activeSessionExerciseId,
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
      targetEndTime: targetEndTime != null
          ? targetEndTime()
          : this.targetEndTime,
      exerciseName: exerciseName != null ? exerciseName() : this.exerciseName,
      activeSessionExerciseId: activeSessionExerciseId != null
          ? activeSessionExerciseId()
          : this.activeSessionExerciseId,
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
  /// Notification ID for the sound/vibration alarm when rest timer reaches 0:00.
  static const int _kRestAlarmNotificationId = 9001;

  /// Notification ID for the live ongoing workout & rest tracker in the status bar.
  static const int _kOngoingWorkoutNotificationId = 9002;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _notificationsInitialized = false;
  bool _permissionRequested = false;
  bool _hasPlayedCompletionSoundForCurrentRest = false;
  Timer? _uiRefreshTimer;
  ActiveWorkoutSessionDetails? _latestSessionDetails;

  @override
  RestTimerState build() {
    ref.onDispose(() {
      _uiRefreshTimer?.cancel();
    });

    _ensureNotificationsInitialized();

    // Reactively track the active workout session to keep the ongoing status bar
    // notification updated with current workout, exercise, set number, and rest time.
    ref.listen<AsyncValue<ActiveWorkoutSessionDetails?>>(
      activeWorkoutSessionStreamProvider,
      (previous, next) {
        if (!next.hasValue) return;
        final details = next.value;
        _latestSessionDetails = details;
        if (details == null) {
          unawaited(_cancelOngoingWorkoutNotification());
        } else {
          unawaited(_refreshOngoingWorkoutNotification());
        }
      },
      fireImmediately: true,
    );

    return const RestTimerState();
  }

  Future<void> _ensureNotificationsInitialized() async {
    if (_notificationsInitialized) return;
    try {
      tz_data.initializeTimeZones();
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
        macOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(
          defaultActionName: 'Open notification',
        ),
      );
      await _notificationsPlugin.initialize(settings: initializationSettings);
      _notificationsInitialized = true;
      await _requestPermissionsIfNeeded();
    } catch (_) {
      // Gracefully ignore in environments where notifications are unsupported.
    }
  }

  Future<void> _requestPermissionsIfNeeded() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Ignore permission request errors on unsupported platforms.
    }
  }

  void _startUiRefreshTicker() {
    _uiRefreshTimer?.cancel();
    _uiRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isRunning || state.lastSetCompletedAt != null) {
        if (state.isRunning &&
            !_hasPlayedCompletionSoundForCurrentRest &&
            state.remainingSeconds <= 0) {
          _hasPlayedCompletionSoundForCurrentRest = true;
          final userPrefs = ref.read(userPreferencesProvider);
          if (userPrefs.restSoundEnabled) {
            unawaited(RestSoundPlayer.play(userPrefs.restSoundType));
          }
        }
        state = state.copyWith(tick: state.tick + 1);
        if (state.isRunning || state.nextSupersetBanner != null) {
          unawaited(_refreshOngoingWorkoutNotification());
        }
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
  Future<int> onSetCompleted({
    required ActiveWorkoutSessionDetails sessionDetails,
    required ActiveSessionExerciseBundle currentExerciseBundle,
    required int completedSetNumber,
    required SetType completedSetType,
    int? customSetTargetRestSeconds,
  }) async {
    _latestSessionDetails = sessionDetails;
    final now = DateTime.now().toUtc();
    final settings = await ref
        .read(appSettingsRepositoryProvider)
        .getSettings();

    final resolvedTargetRest = AppSettingsRepository.resolveTargetRestSeconds(
      settings: settings,
      setType: completedSetType,
      muscleSizeCategory: currentExerciseBundle.exercise.muscleSizeCategory,
      customWorkingRestSeconds:
          customSetTargetRestSeconds ??
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
            await _cancelScheduledRestAlarm();
            state = RestTimerState(
              isRunning: false,
              lastSetCompletedAt: now,
              targetRestSeconds: resolvedTargetRest,
              targetEndTime: null,
              exerciseName: candidate.exercise.name,
              activeSessionExerciseId: candidate.sessionExercise.id,
              nextSupersetExerciseId: candidate.sessionExercise.id,
              nextSupersetBanner:
                  'Lanjut Superset ${candidate.supersetBadge ?? ""}: '
                  '${candidate.exercise.name} (Set $completedSetNumber)',
              tick: state.tick + 1,
            );
            _startUiRefreshTicker();
            await _refreshOngoingWorkoutNotification();
            return resolvedTargetRest;
          }
        }
      }
    }

    // Standard set or final exercise in a superset round -> start main Rest Timer
    final endTime = now.add(Duration(seconds: resolvedTargetRest));
    _hasPlayedCompletionSoundForCurrentRest = false;
    state = RestTimerState(
      isRunning: true,
      lastSetCompletedAt: now,
      targetRestSeconds: resolvedTargetRest,
      targetEndTime: endTime,
      exerciseName: currentExerciseBundle.exercise.name,
      activeSessionExerciseId: currentExerciseBundle.sessionExercise.id,
      nextSupersetExerciseId: null,
      nextSupersetBanner: null,
      tick: state.tick + 1,
    );

    _startUiRefreshTicker();
    await _scheduleRestFinishedNotification(
      targetEndTime: endTime,
      targetRestSeconds: resolvedTargetRest,
      sessionDetails: sessionDetails,
      currentExerciseBundle: currentExerciseBundle,
      completedSetNumber: completedSetNumber,
    );
    await _refreshOngoingWorkoutNotification();

    return resolvedTargetRest;
  }

  /// Adjusts the active target rest duration by [deltaSeconds] (e.g. `+15` or `-15`).
  Future<void> adjustTargetRest(int deltaSeconds) async {
    final start = state.lastSetCompletedAt;
    if (!state.isRunning || start == null) return;

    final updatedTarget = (state.targetRestSeconds + deltaSeconds).clamp(
      5,
      900,
    );
    final updatedEnd = start.add(Duration(seconds: updatedTarget));

    state = state.copyWith(
      targetRestSeconds: updatedTarget,
      targetEndTime: () => updatedEnd,
      tick: state.tick + 1,
    );

    if (updatedEnd.isAfter(DateTime.now().toUtc())) {
      _hasPlayedCompletionSoundForCurrentRest = false;
      await _scheduleRestFinishedNotification(
        targetEndTime: updatedEnd,
        targetRestSeconds: updatedTarget,
        sessionDetails: _latestSessionDetails,
        fallbackExerciseName: state.exerciseName ?? 'Latihan',
      );
    } else {
      await _cancelScheduledRestAlarm();
    }
    await _refreshOngoingWorkoutNotification();
  }

  /// Dismisses the countdown bar and cancels any pending rest alarm while
  /// preserving `lastSetCompletedAt` so `actualRestSeconds` is still recorded
  /// when Set N+1 is completed.
  Future<void> skipTimer() async {
    _hasPlayedCompletionSoundForCurrentRest = true;
    await _cancelScheduledRestAlarm();
    state = state.copyWith(
      isRunning: false,
      targetEndTime: () => null,
      nextSupersetBanner: () => null,
      nextSupersetExerciseId: () => null,
      tick: state.tick + 1,
    );
    await _refreshOngoingWorkoutNotification();
  }

  /// Resets the timer completely and clears all notifications when a workout
  /// session finishes or is discarded.
  Future<void> resetAll() async {
    _uiRefreshTimer?.cancel();
    _latestSessionDetails = null;
    _hasPlayedCompletionSoundForCurrentRest = true;
    await _cancelScheduledRestAlarm();
    await _cancelOngoingWorkoutNotification();
    state = const RestTimerState();
  }

  // ---------------------------------------------------------------------------
  // LIVE ONGOING WORKOUT & REST TRACKER NOTIFICATION
  // ---------------------------------------------------------------------------

  /// Resolves the active/next exercise and set number in [details] so the
  /// notification always displays which exercise, machine, and set the user is on.
  ({
    ActiveSessionExerciseBundle? exerciseBundle,
    int currentSetNumber,
    int totalSetsForExercise,
    SetType setType,
    double? targetWeight,
    int? targetReps,
    bool allSessionSetsCompleted,
  })
  _resolveCurrentExerciseAndSet(ActiveWorkoutSessionDetails details) {
    if (details.exercises.isEmpty) {
      return (
        exerciseBundle: null,
        currentSetNumber: 1,
        totalSetsForExercise: 0,
        setType: SetType.normal,
        targetWeight: null,
        targetReps: null,
        allSessionSetsCompleted: false,
      );
    }

    // 1. If a superset next exercise or active exercise is focused, check it first
    final preferredId =
        state.nextSupersetExerciseId ?? state.activeSessionExerciseId;
    if (preferredId != null) {
      final preferredBundle = details.exercises
          .where((e) => e.sessionExercise.id == preferredId)
          .firstOrNull;
      if (preferredBundle != null) {
        final nextIncomplete = preferredBundle.sets
            .where((s) => !s.isCompleted)
            .firstOrNull;
        if (nextIncomplete != null) {
          return (
            exerciseBundle: preferredBundle,
            currentSetNumber: nextIncomplete.setNumber,
            totalSetsForExercise: preferredBundle.sets.length,
            setType: nextIncomplete.setType,
            targetWeight: nextIncomplete.weight,
            targetReps: nextIncomplete.reps,
            allSessionSetsCompleted: false,
          );
        }
      }
    }

    // 2. Otherwise find the first exercise in the session with an incomplete set
    for (final bundle in details.exercises) {
      final nextIncomplete = bundle.sets
          .where((s) => !s.isCompleted)
          .firstOrNull;
      if (nextIncomplete != null) {
        return (
          exerciseBundle: bundle,
          currentSetNumber: nextIncomplete.setNumber,
          totalSetsForExercise: bundle.sets.length,
          setType: nextIncomplete.setType,
          targetWeight: nextIncomplete.weight,
          targetReps: nextIncomplete.reps,
          allSessionSetsCompleted: false,
        );
      }
    }

    // 3. All sets in the session are completed
    final lastBundle = details.exercises.last;
    final lastSet = lastBundle.sets.lastOrNull;
    return (
      exerciseBundle: lastBundle,
      currentSetNumber: lastSet?.setNumber ?? lastBundle.sets.length,
      totalSetsForExercise: lastBundle.sets.length,
      setType: lastSet?.setType ?? SetType.normal,
      targetWeight: lastSet?.weight,
      targetReps: lastSet?.reps,
      allSessionSetsCompleted: true,
    );
  }

  /// Posts or updates the ongoing status-bar notification showing:
  /// - Which Workout & Gym is active
  /// - Which Exercise, Machine Brand, and Set Number (`Set X dari Y`) the user is on
  /// - Live Rest Timer countdown (`Rest mm:ss / Target mm:ss`) + progress bar when resting
  Future<void> _refreshOngoingWorkoutNotification() async {
    final details = _latestSessionDetails;
    if (details == null) {
      await _cancelOngoingWorkoutNotification();
      return;
    }

    await _ensureNotificationsInitialized();
    await _requestPermissionsIfNeeded();

    final workoutTitle = details.workoutPlan?.name ?? 'Empty Workout';
    final gymName = details.gymLocation?.name ?? 'Gym';
    final completedSets = details.completedSetsCount;
    final totalSets = details.totalSetsCount;

    final current = _resolveCurrentExerciseAndSet(details);
    final bundle = current.exerciseBundle;
    final exName = bundle?.exercise.name ?? 'Belum ada gerakan';
    final machineBrand = bundle?.selectedMachine?.brandName;
    final defaultWeightUnit = ref
        .read(userPreferencesProvider)
        .weightUnit
        .toDatabaseWeightUnit();
    final unit = bundle?.selectedMachine?.weightUnit ?? defaultWeightUnit;
    final machineTag = (machineBrand != null && machineBrand.isNotEmpty)
        ? ' ($machineBrand)'
        : '';

    final setLabel = current.setType == SetType.warmup
        ? 'Warm-up Set #${current.currentSetNumber}/${current.totalSetsForExercise}'
        : current.setType == SetType.dropset
        ? 'Drop Set #${current.currentSetNumber}/${current.totalSetsForExercise}'
        : current.setType == SetType.failure
        ? 'Failure Set #${current.currentSetNumber}/${current.totalSetsForExercise}'
        : 'Set #${current.currentSetNumber}/${current.totalSetsForExercise}';

    String loadHint = '';
    if (current.targetWeight != null && current.targetReps != null) {
      final w = current.targetWeight!;
      final wStr = w == w.roundToDouble() ? w.toInt().toString() : w.toString();
      loadHint = ' • $wStr${unit.label.toLowerCase()} × ${current.targetReps}';
    } else if (current.targetReps != null) {
      loadHint = ' • ${current.targetReps} reps';
    }

    late final String notifTitle;
    late final String notifBody;
    late final AndroidNotificationDetails androidDetails;

    if (state.isRunning && state.targetEndTime != null) {
      // CASE 1: Smart Rest Timer is actively running
      final remaining = state.remainingSeconds;
      final elapsed = state.elapsedSeconds;
      final target = state.targetRestSeconds;
      final isOvertime = remaining < 0;

      notifTitle = isOvertime
          ? '🔥 Overtime +${formatRestDuration(remaining.abs())} (Rest: ${formatRestDuration(elapsed)})'
          : '⏱ Rest: ${formatRestDuration(remaining)} / ${formatRestDuration(target)}';

      notifBody = current.allSessionSetsCompleted
          ? '$workoutTitle ($gymName) • Semua $totalSets set selesai!'
          : 'Berikutnya: $setLabel — $exName$machineTag$loadHint ($completedSets/$totalSets set)';

      androidDetails = AndroidNotificationDetails(
        'active_workout_tracker_channel',
        'Active Workout & Rest Tracker',
        channelDescription: 'Menampilkan progres set latihan aktif dan hitung mundur waktu istirahat',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        silent: true,
        playSound: false,
        enableVibration: false,
        showWhen: true,
        when: isOvertime
            ? state.lastSetCompletedAt?.millisecondsSinceEpoch
            : state.targetEndTime?.millisecondsSinceEpoch,
        usesChronometer: true,
        chronometerCountDown: !isOvertime,
        showProgress: true,
        maxProgress: target > 0 ? target : 1,
        progress: elapsed.clamp(0, target > 0 ? target : 1),
        subText: '$workoutTitle • $gymName',
        styleInformation: BigTextStyleInformation(
          notifBody,
          contentTitle: notifTitle,
          summaryText: '$workoutTitle • $completedSets/$totalSets Set',
        ),
      );
    } else if (state.nextSupersetBanner != null) {
      // CASE 2: Superset Transition between movements
      notifTitle = '⚡ ${state.nextSupersetBanner!}';
      notifBody =
          '$workoutTitle ($gymName) • Transisi: ${formatRestDuration(state.elapsedSeconds)} • Total: $completedSets/$totalSets set';

      androidDetails = AndroidNotificationDetails(
        'active_workout_tracker_channel',
        'Active Workout & Rest Tracker',
        channelDescription: 'Menampilkan progres set latihan aktif dan hitung mundur waktu istirahat',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        silent: true,
        playSound: false,
        enableVibration: false,
        showWhen: true,
        when: state.lastSetCompletedAt?.millisecondsSinceEpoch,
        usesChronometer: true,
        chronometerCountDown: false,
        subText: '$workoutTitle • Superset',
        styleInformation: BigTextStyleInformation(
          notifBody,
          contentTitle: notifTitle,
        ),
      );
    } else {
      // CASE 3: Actively lifting / working on current set
      notifTitle = bundle == null
          ? '🏋️ $workoutTitle ($gymName)'
          : current.allSessionSetsCompleted
          ? '✅ Semua $totalSets Set Selesai! ($workoutTitle)'
          : '🏋️ $setLabel • $exName$machineTag';

      notifBody = bundle == null
          ? 'Sesi latihan aktif — Tambahkan gerakan untuk mulai mencatat set.'
          : current.allSessionSetsCompleted
          ? '$workoutTitle ($gymName) • Ketuk untuk menyelesaikan sesi latihan.'
          : 'Workout: $workoutTitle ($gymName)$loadHint • Selesai: $completedSets/$totalSets set';

      androidDetails = AndroidNotificationDetails(
        'active_workout_tracker_channel',
        'Active Workout & Rest Tracker',
        channelDescription: 'Menampilkan progres set latihan aktif dan hitung mundur waktu istirahat',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        silent: true,
        playSound: false,
        enableVibration: false,
        showWhen: true,
        when: details.session.startedAt.millisecondsSinceEpoch,
        usesChronometer: true,
        chronometerCountDown: false,
        subText: '$workoutTitle • $completedSets/$totalSets Set',
        styleInformation: BigTextStyleInformation(
          notifBody,
          contentTitle: notifTitle,
          summaryText: '$workoutTitle • $gymName',
        ),
      );
    }

    try {
      await _notificationsPlugin.show(
        id: _kOngoingWorkoutNotificationId,
        title: notifTitle,
        body: notifBody,
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(
            presentAlert: false,
            presentSound: false,
            presentBanner: false,
            presentList: true,
          ),
        ),
      );
    } catch (_) {
      // Ignore notification errors on unsupported platforms.
    }
  }

  Future<void> _scheduleRestFinishedNotification({
    required DateTime targetEndTime,
    required int targetRestSeconds,
    ActiveWorkoutSessionDetails? sessionDetails,
    ActiveSessionExerciseBundle? currentExerciseBundle,
    int? completedSetNumber,
    String? fallbackExerciseName,
  }) async {
    await _ensureNotificationsInitialized();
    await _cancelScheduledRestAlarm();

    if (!targetEndTime.isAfter(DateTime.now().toUtc())) return;

    final workoutTitle = sessionDetails?.workoutPlan?.name ?? 'Workout';
    final exName =
        currentExerciseBundle?.exercise.name ??
        fallbackExerciseName ??
        'Latihan';
    final brand = currentExerciseBundle?.selectedMachine?.brandName;
    final machinePart = (brand != null && brand.isNotEmpty) ? ' ($brand)' : '';
    final nextSetNum = completedSetNumber != null
        ? completedSetNumber + 1
        : null;
    final nextSetText = nextSetNum != null
        ? 'Set #$nextSetNum'
        : 'set berikutnya';

    try {
      final userPrefs = ref.read(userPreferencesProvider);
      final soundEnabled = userPrefs.restSoundEnabled;
      final channelId = soundEnabled
          ? 'rest_timer_channel_sound'
          : 'rest_timer_channel_silent';
      final scheduledDate = tz.TZDateTime.from(targetEndTime, tz.local);
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Smart Rest Timer Alarm',
          channelDescription: 'Alarm saat waktu istirahat antar set selesai',
          importance: Importance.max,
          priority: Priority.high,
          playSound: soundEnabled,
          enableVibration: true,
          subText: workoutTitle,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: soundEnabled,
        ),
      );

      await _notificationsPlugin.zonedSchedule(
        id: _kRestAlarmNotificationId,
        title: 'Rest ${formatCompactDuration(targetRestSeconds)} Selesai! 💪',
        body:
            'Saatnya mulai $nextSetText pada $exName$machinePart ($workoutTitle).',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // Ignore scheduling errors on desktop/test environments.
    }
  }

  Future<void> _cancelScheduledRestAlarm() async {
    try {
      await _notificationsPlugin.cancel(id: _kRestAlarmNotificationId);
    } catch (_) {
      // Ignore cancellation errors on unsupported platforms.
    }
  }

  Future<void> _cancelOngoingWorkoutNotification() async {
    try {
      await _notificationsPlugin.cancel(id: _kOngoingWorkoutNotificationId);
    } catch (_) {
      // Ignore cancellation errors on unsupported platforms.
    }
  }
}
