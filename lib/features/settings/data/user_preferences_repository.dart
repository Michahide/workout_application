import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/tables.dart';

/// Sound types available when the Smart Rest Timer reaches 0:00.
enum RestSoundType {
  gymBeep,
  boxingBell,
  chimeFanfare,
  digitalAlarm,
  systemDefault;

  String get label => switch (this) {
        RestSoundType.gymBeep => 'Gym Timer Beep',
        RestSoundType.boxingBell => 'Boxing / Gym Bell',
        RestSoundType.chimeFanfare => 'Energetic Chime',
        RestSoundType.digitalAlarm => 'Digital Double Alarm',
        RestSoundType.systemDefault => 'Nada Notifikasi HP',
      };

  String get description => switch (this) {
        RestSoundType.gymBeep => 'Beep 3x ala timer gym (Beep-Beep-BEEP!)',
        RestSoundType.boxingBell => 'Dentang lonceng ronde gym / tinju',
        RestSoundType.chimeFanfare => 'Nada harmoni naik (C5–E5–G5–C6)',
        RestSoundType.digitalAlarm => 'Alarm jam digital 2x pulse cepat',
        RestSoundType.systemDefault => 'Suara notifikasi bawaan perangkat',
      };
}

/// Global preferred weight unit (defaults to `kg`).
enum PreferredWeightUnit {
  kg,
  lbs;

  String get label => switch (this) {
        PreferredWeightUnit.kg => 'kg',
        PreferredWeightUnit.lbs => 'lbs',
      };

  String get fullLabel => switch (this) {
        PreferredWeightUnit.kg => 'Kilogram (kg)',
        PreferredWeightUnit.lbs => 'Pounds (lbs)',
      };

  WeightUnit toDatabaseWeightUnit() => switch (this) {
        PreferredWeightUnit.kg => WeightUnit.KG,
        PreferredWeightUnit.lbs => WeightUnit.LBS,
      };
}

/// Global preferred distance unit (defaults to `km`).
enum PreferredDistanceUnit {
  km,
  miles;

  String get label => switch (this) {
        PreferredDistanceUnit.km => 'km',
        PreferredDistanceUnit.miles => 'miles',
      };

  String get fullLabel => switch (this) {
        PreferredDistanceUnit.km => 'Kilometer / Meter (km)',
        PreferredDistanceUnit.miles => 'Miles (mi)',
      };

  String get columnHeaderLabel => switch (this) {
        PreferredDistanceUnit.km => 'METER',
        PreferredDistanceUnit.miles => 'MILES',
      };
}

/// Global preferred body/equipment measurement unit (defaults to `cm`).
enum PreferredMeasurementUnit {
  cm,
  inch;

  String get label => switch (this) {
        PreferredMeasurementUnit.cm => 'cm',
        PreferredMeasurementUnit.inch => 'in',
      };

  String get fullLabel => switch (this) {
        PreferredMeasurementUnit.cm => 'Centimeter (cm)',
        PreferredMeasurementUnit.inch => 'Inches (in)',
      };
}

/// Immutable state holding user preferences for Rest Timer Sound and Units.
///
/// Defaults strictly to:
/// - `restSoundEnabled`: `true`
/// - `restSoundType`: `RestSoundType.gymBeep`
/// - `weightUnit`: `PreferredWeightUnit.kg`
/// - `distanceUnit`: `PreferredDistanceUnit.km`
/// - `measurementUnit`: `PreferredMeasurementUnit.cm`
class UserPreferences {
  const UserPreferences({
    this.restSoundEnabled = true,
    this.restSoundType = RestSoundType.gymBeep,
    this.weightUnit = PreferredWeightUnit.kg,
    this.distanceUnit = PreferredDistanceUnit.km,
    this.measurementUnit = PreferredMeasurementUnit.cm,
  });

  final bool restSoundEnabled;
  final RestSoundType restSoundType;
  final PreferredWeightUnit weightUnit;
  final PreferredDistanceUnit distanceUnit;
  final PreferredMeasurementUnit measurementUnit;

  UserPreferences copyWith({
    bool? restSoundEnabled,
    RestSoundType? restSoundType,
    PreferredWeightUnit? weightUnit,
    PreferredDistanceUnit? distanceUnit,
    PreferredMeasurementUnit? measurementUnit,
  }) {
    return UserPreferences(
      restSoundEnabled: restSoundEnabled ?? this.restSoundEnabled,
      restSoundType: restSoundType ?? this.restSoundType,
      weightUnit: weightUnit ?? this.weightUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      measurementUnit: measurementUnit ?? this.measurementUnit,
    );
  }
}

/// Native sound player that invokes the Android `AudioTrack` / `RingtoneManager`
/// method channel and gracefully falls back to `SystemSound` + `HapticFeedback`.
class RestSoundPlayer {
  static const MethodChannel _channel = MethodChannel(
    'com.example.workout_application/rest_sound',
  );

  static Future<void> play(RestSoundType soundType) async {
    try {
      await _channel.invokeMethod<void>('playRestSound', {
        'soundType': soundType.name,
      });
    } catch (_) {
      try {
        await HapticFeedback.heavyImpact();
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }
}

class UserPreferencesNotifier extends Notifier<UserPreferences> {
  static const _kRestSoundEnabledKey = 'pref_rest_sound_enabled';
  static const _kRestSoundTypeKey = 'pref_rest_sound_type';
  static const _kWeightUnitKey = 'pref_unit_weight';
  static const _kDistanceUnitKey = 'pref_unit_distance';
  static const _kMeasurementUnitKey = 'pref_unit_measurement';

  @override
  UserPreferences build() {
    _loadFromPrefs();
    return const UserPreferences();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final soundEnabled = prefs.getBool(_kRestSoundEnabledKey) ?? true;
    final soundTypeName = prefs.getString(_kRestSoundTypeKey);
    final weightName = prefs.getString(_kWeightUnitKey);
    final distanceName = prefs.getString(_kDistanceUnitKey);
    final measurementName = prefs.getString(_kMeasurementUnitKey);

    final soundType = RestSoundType.values
            .where((e) => e.name == soundTypeName)
            .firstOrNull ??
        RestSoundType.gymBeep;
    final weightUnit = PreferredWeightUnit.values
            .where((e) => e.name == weightName)
            .firstOrNull ??
        PreferredWeightUnit.kg;
    final distanceUnit = PreferredDistanceUnit.values
            .where((e) => e.name == distanceName)
            .firstOrNull ??
        PreferredDistanceUnit.km;
    final measurementUnit = PreferredMeasurementUnit.values
            .where((e) => e.name == measurementName)
            .firstOrNull ??
        PreferredMeasurementUnit.cm;

    state = UserPreferences(
      restSoundEnabled: soundEnabled,
      restSoundType: soundType,
      weightUnit: weightUnit,
      distanceUnit: distanceUnit,
      measurementUnit: measurementUnit,
    );
  }

  Future<void> setRestSoundEnabled(bool enabled) async {
    state = state.copyWith(restSoundEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRestSoundEnabledKey, enabled);
    if (enabled) {
      await RestSoundPlayer.play(state.restSoundType);
    }
  }

  Future<void> setRestSoundType(
    RestSoundType soundType, {
    bool playPreview = true,
  }) async {
    state = state.copyWith(restSoundType: soundType);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRestSoundTypeKey, soundType.name);
    if (playPreview && state.restSoundEnabled) {
      await RestSoundPlayer.play(soundType);
    }
  }

  Future<void> previewCurrentSound() async {
    await RestSoundPlayer.play(state.restSoundType);
  }

  Future<void> setWeightUnit(PreferredWeightUnit unit) async {
    state = state.copyWith(weightUnit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWeightUnitKey, unit.name);
  }

  Future<void> setDistanceUnit(PreferredDistanceUnit unit) async {
    state = state.copyWith(distanceUnit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDistanceUnitKey, unit.name);
  }

  Future<void> setMeasurementUnit(PreferredMeasurementUnit unit) async {
    state = state.copyWith(measurementUnit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMeasurementUnitKey, unit.name);
  }
}

final userPreferencesProvider =
    NotifierProvider<UserPreferencesNotifier, UserPreferences>(
  UserPreferencesNotifier.new,
);
