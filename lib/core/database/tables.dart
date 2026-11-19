// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:drift/drift.dart';

import 'syncable_table_mixin.dart';

/// Weight unit configurable per gym machine.
enum WeightUnit {
  KG,
  LBS,
  STACK_NUMBER,
}

/// Equipment category for exercises.
enum EquipmentCategory {
  machine,
  cable,
  barbell,
  dumbbell,
  bodyweight,
  smith_machine,
  trap_bar,
  kettlebell,
  band,
  other,
}

/// Muscle size classification used for default warm-up rest timers.
enum MuscleSizeCategory {
  LARGE,
  SMALL,
}

/// Primary and secondary muscle groups.
enum MuscleGroup {
  chest(MuscleSizeCategory.LARGE),
  lats(MuscleSizeCategory.LARGE),
  upper_back(MuscleSizeCategory.LARGE),
  quads(MuscleSizeCategory.LARGE),
  hamstrings(MuscleSizeCategory.LARGE),
  glutes(MuscleSizeCategory.LARGE),
  front_delts(MuscleSizeCategory.SMALL),
  side_delts(MuscleSizeCategory.SMALL),
  rear_delts(MuscleSizeCategory.SMALL),
  biceps(MuscleSizeCategory.SMALL),
  triceps(MuscleSizeCategory.SMALL),
  calves(MuscleSizeCategory.SMALL),
  abs(MuscleSizeCategory.SMALL),
  forearms(MuscleSizeCategory.SMALL),
  traps(MuscleSizeCategory.SMALL);

  const MuscleGroup(this.defaultSizeCategory);

  /// Default muscle size category inferred from the muscle group.
  final MuscleSizeCategory defaultSizeCategory;
}

/// Exercise tracking and progression type (8 types per SPEC.md).
enum ExerciseType {
  weight_reps,
  bodyweight_reps,
  weighted_bodyweight,
  assisted_bodyweight,
  duration,
  duration_weight,
  distance_duration,
  weight_distance,
}

/// Media attachment type for exercises.
enum MediaType {
  photo,
  video,
}

/// Cloud upload status for compressed local media files.
enum MediaSyncStatus {
  local_only,
  uploading,
  uploaded,
}

/// Set classification within a workout session.
enum SetType {
  warmup,
  normal,
  dropset,
  failure,
}

/// Spotter / assistance level for a completed set.
enum AssistanceType {
  solo,
  spotted_no_touch,
  assisted,
}

/// Drift TypeConverter for storing a `List<MuscleGroup>` as a JSON string.
class MuscleGroupListConverter extends TypeConverter<List<MuscleGroup>, String> {
  const MuscleGroupListConverter();

  @override
  List<MuscleGroup> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded
        .map((e) => MuscleGroup.values.byName(e as String))
        .toList(growable: false);
  }

  @override
  String toSql(List<MuscleGroup> value) {
    return jsonEncode(value.map((e) => e.name).toList(growable: false));
  }
}

/// Drift TypeConverter for storing a generic `List<String>` as a JSON string.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded.map((e) => e as String).toList(growable: false);
  }

  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}

/// Registered gym locations (e.g., "Gym A", "Gym B").
class GymLocations extends Table with SyncableTableMixin {
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
}

/// Built-in and user-created exercises.
class Exercises extends Table with SyncableTableMixin {
  TextColumn get name => text()();
  TextColumn get equipmentCategory => textEnum<EquipmentCategory>()();
  TextColumn get primaryMuscleGroup => textEnum<MuscleGroup>()();
  TextColumn get secondaryMuscleGroups => text()
      .map(const MuscleGroupListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get muscleSizeCategory => textEnum<MuscleSizeCategory>()();
  TextColumn get exerciseType => textEnum<ExerciseType>()();
  IntColumn get defaultWorkingRestSeconds => integer().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

/// Specific equipment/machines tied to a gym location (or global if `gymLocationId` is null).
class GymMachines extends Table with SyncableTableMixin {
  TextColumn get gymLocationId => text()
      .nullable()
      .references(GymLocations, #id, onDelete: KeyAction.setNull)();
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();
  TextColumn get brandName => text().nullable()();
  TextColumn get weightUnit =>
      textEnum<WeightUnit>().withDefault(Constant(WeightUnit.KG.name))();
  TextColumn get pinnedNotes => text().nullable()();
}

/// Compressed photo/video media attachments for an exercise and specific gym machine
/// (max 4 photos, 3 videos per machine/exercise).
class ExerciseMedia extends Table with SyncableTableMixin {
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();
  TextColumn get gymMachineId => text()
      .nullable()
      .references(GymMachines, #id, onDelete: KeyAction.cascade)();
  TextColumn get mediaType => textEnum<MediaType>()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get localPath => text()();
  TextColumn get thumbnailLocalPath => text().nullable()();
  IntColumn get fileSizeBytes => integer()();
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get thumbnailRemoteUrl => text().nullable()();
  TextColumn get mediaSyncStatus => textEnum<MediaSyncStatus>()
      .withDefault(Constant(MediaSyncStatus.local_only.name))();
}

/// User-defined workout routines/plans (e.g., "Push Day", "Upper Body A").
class WorkoutPlans extends Table with SyncableTableMixin {
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
}

/// Ordered exercises within a workout plan, including superset grouping and targets.
class WorkoutPlanExercises extends Table with SyncableTableMixin {
  TextColumn get workoutPlanId =>
      text().references(WorkoutPlans, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();
  TextColumn get defaultGymMachineId => text()
      .nullable()
      .references(GymMachines, #id, onDelete: KeyAction.setNull)();
  IntColumn get sortOrder => integer()();
  TextColumn get supersetGroupId => text().nullable()();
  IntColumn get targetSets => integer().withDefault(const Constant(3))();
  IntColumn get targetReps => integer().nullable()();
  IntColumn get targetRestSeconds => integer().nullable()();
}

/// Active or completed workout sessions.
class WorkoutSessions extends Table with SyncableTableMixin {
  TextColumn get workoutPlanId => text()
      .nullable()
      .references(WorkoutPlans, #id, onDelete: KeyAction.setNull)();
  TextColumn get gymLocationId => text()
      .nullable()
      .references(GymLocations, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get sessionNotes => text().nullable()();
}

/// Ordered exercises performed during a specific workout session.
class WorkoutSessionExercises extends Table with SyncableTableMixin {
  TextColumn get workoutSessionId =>
      text().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.restrict)();
  TextColumn get gymMachineId => text()
      .nullable()
      .references(GymMachines, #id, onDelete: KeyAction.setNull)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get supersetGroupId => text().nullable()();
}

/// Individual sets logged under a workout session exercise.
class WorkoutSets extends Table with SyncableTableMixin {
  TextColumn get workoutSessionExerciseId => text().references(
        WorkoutSessionExercises,
        #id,
        onDelete: KeyAction.cascade,
      )();
  IntColumn get setNumber => integer()();
  TextColumn get parentSetId => text()
      .nullable()
      .references(WorkoutSets, #id, onDelete: KeyAction.cascade)();
  TextColumn get setType =>
      textEnum<SetType>().withDefault(Constant(SetType.normal.name))();
  RealColumn get weight => real().nullable()();
  IntColumn get reps => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  RealColumn get distanceMeters => real().nullable()();
  RealColumn get rpe => real().nullable()();
  TextColumn get assistanceType => textEnum<AssistanceType>()
      .withDefault(Constant(AssistanceType.solo.name))();
  IntColumn get targetRestSeconds => integer().nullable()();
  IntColumn get actualRestSeconds => integer().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// Singleton/configuration table for rest timer defaults and app settings.
class AppSettings extends Table with SyncableTableMixin {
  BoolColumn get useSplitWarmupRest =>
      boolean().withDefault(const Constant(true))();
  IntColumn get largeMuscleWarmupRestSeconds =>
      integer().withDefault(const Constant(90))();
  IntColumn get smallMuscleWarmupRestSeconds =>
      integer().withDefault(const Constant(60))();
  IntColumn get globalWarmupRestSeconds =>
      integer().withDefault(const Constant(60))();
  IntColumn get defaultWorkingSetRestSeconds =>
      integer().withDefault(const Constant(180))();
}
