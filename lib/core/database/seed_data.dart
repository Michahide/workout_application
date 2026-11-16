import 'package:drift/drift.dart';

import 'app_database.dart';
import 'syncable_table_mixin.dart';
import 'tables.dart';

/// Deterministic UUID for the singleton AppSettings row.
const String kDefaultAppSettingsId = '00000000-0000-4000-8000-000000000001';

/// Seeds the initial `AppSettings` and 20 built-in exercises with deterministic UUIDs.
/// Invoked once inside `AppDatabase.migration.onCreate`.
Future<void> seedInitialData(AppDatabase db) async {
  final seedTimestamp = DateTime.utc(2026, 1, 1);

  await db.into(db.appSettings).insert(
        AppSettingsCompanion.insert(
          id: const Value(kDefaultAppSettingsId),
          createdAt: Value(seedTimestamp),
          updatedAt: Value(seedTimestamp),
          syncStatus: Value(SyncStatus.synced),
          useSplitWarmupRest: const Value(true),
          largeMuscleWarmupRestSeconds: const Value(90),
          smallMuscleWarmupRestSeconds: const Value(60),
          globalWarmupRestSeconds: const Value(60),
          defaultWorkingSetRestSeconds: const Value(180),
        ),
        mode: InsertMode.insertOrIgnore,
      );

  final builtInExercises = <ExercisesCompanion>[
    // 1. Barbell Bench Press (LARGE - Chest - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000001',
      name: 'Barbell Bench Press',
      equipmentCategory: EquipmentCategory.barbell,
      primaryMuscleGroup: MuscleGroup.chest,
      secondaryMuscleGroups: const [
        MuscleGroup.front_delts,
        MuscleGroup.triceps,
      ],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 2. Machine Chest Press (LARGE - Chest - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000002',
      name: 'Machine Chest Press',
      equipmentCategory: EquipmentCategory.machine,
      primaryMuscleGroup: MuscleGroup.chest,
      secondaryMuscleGroups: const [
        MuscleGroup.front_delts,
        MuscleGroup.triceps,
      ],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 3. Incline Dumbbell Press (LARGE - Chest - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000003',
      name: 'Incline Dumbbell Press',
      equipmentCategory: EquipmentCategory.dumbbell,
      primaryMuscleGroup: MuscleGroup.chest,
      secondaryMuscleGroups: const [
        MuscleGroup.front_delts,
        MuscleGroup.triceps,
      ],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 4. Lat Pulldown (LARGE - Lats - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000004',
      name: 'Lat Pulldown',
      equipmentCategory: EquipmentCategory.cable,
      primaryMuscleGroup: MuscleGroup.lats,
      secondaryMuscleGroups: const [
        MuscleGroup.biceps,
        MuscleGroup.upper_back,
      ],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 5. Assisted Pull-Up (LARGE - Lats - assisted_bodyweight)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000005',
      name: 'Assisted Pull-Up',
      equipmentCategory: EquipmentCategory.machine,
      primaryMuscleGroup: MuscleGroup.lats,
      secondaryMuscleGroups: const [
        MuscleGroup.biceps,
        MuscleGroup.upper_back,
      ],
      exerciseType: ExerciseType.assisted_bodyweight,
      seedTimestamp: seedTimestamp,
    ),
    // 6. Weighted Pull-Up (LARGE - Lats - weighted_bodyweight)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000006',
      name: 'Weighted Pull-Up',
      equipmentCategory: EquipmentCategory.bodyweight,
      primaryMuscleGroup: MuscleGroup.lats,
      secondaryMuscleGroups: const [
        MuscleGroup.biceps,
        MuscleGroup.upper_back,
        MuscleGroup.forearms,
      ],
      exerciseType: ExerciseType.weighted_bodyweight,
      seedTimestamp: seedTimestamp,
    ),
    // 7. Seated Cable Row (LARGE - Upper Back - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000007',
      name: 'Seated Cable Row',
      equipmentCategory: EquipmentCategory.cable,
      primaryMuscleGroup: MuscleGroup.upper_back,
      secondaryMuscleGroups: const [
        MuscleGroup.lats,
        MuscleGroup.rear_delts,
        MuscleGroup.biceps,
      ],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 8. Barbell Back Squat (LARGE - Quads - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000008',
      name: 'Barbell Back Squat',
      equipmentCategory: EquipmentCategory.barbell,
      primaryMuscleGroup: MuscleGroup.quads,
      secondaryMuscleGroups: const [
        MuscleGroup.glutes,
        MuscleGroup.hamstrings,
        MuscleGroup.abs,
      ],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 9. Leg Press Machine (LARGE - Quads - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000009',
      name: 'Leg Press',
      equipmentCategory: EquipmentCategory.machine,
      primaryMuscleGroup: MuscleGroup.quads,
      secondaryMuscleGroups: const [
        MuscleGroup.glutes,
        MuscleGroup.hamstrings,
      ],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 10. Romanian Deadlift (LARGE - Hamstrings - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000010',
      name: 'Romanian Deadlift (RDL)',
      equipmentCategory: EquipmentCategory.barbell,
      primaryMuscleGroup: MuscleGroup.hamstrings,
      secondaryMuscleGroups: const [
        MuscleGroup.glutes,
        MuscleGroup.upper_back,
        MuscleGroup.forearms,
      ],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 11. Seated Leg Curl (LARGE - Hamstrings - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000011',
      name: 'Seated Leg Curl',
      equipmentCategory: EquipmentCategory.machine,
      primaryMuscleGroup: MuscleGroup.hamstrings,
      secondaryMuscleGroups: const [MuscleGroup.calves],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 12. Barbell Hip Thrust (LARGE - Glutes - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000012',
      name: 'Barbell Hip Thrust',
      equipmentCategory: EquipmentCategory.barbell,
      primaryMuscleGroup: MuscleGroup.glutes,
      secondaryMuscleGroups: const [
        MuscleGroup.hamstrings,
        MuscleGroup.quads,
      ],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 13. Overhead Barbell Press (SMALL - Front Delts - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000013',
      name: 'Overhead Barbell Press',
      equipmentCategory: EquipmentCategory.barbell,
      primaryMuscleGroup: MuscleGroup.front_delts,
      secondaryMuscleGroups: const [
        MuscleGroup.side_delts,
        MuscleGroup.triceps,
        MuscleGroup.traps,
      ],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 14. Cable Lateral Raise (SMALL - Side Delts - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000014',
      name: 'Cable Lateral Raise',
      equipmentCategory: EquipmentCategory.cable,
      primaryMuscleGroup: MuscleGroup.side_delts,
      secondaryMuscleGroups: const [MuscleGroup.traps],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 15. Rope Face Pull (SMALL - Rear Delts - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000015',
      name: 'Rope Face Pull',
      equipmentCategory: EquipmentCategory.cable,
      primaryMuscleGroup: MuscleGroup.rear_delts,
      secondaryMuscleGroups: const [
        MuscleGroup.upper_back,
        MuscleGroup.traps,
      ],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 16. Incline Dumbbell Curl (SMALL - Biceps - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000016',
      name: 'Incline Dumbbell Curl',
      equipmentCategory: EquipmentCategory.dumbbell,
      primaryMuscleGroup: MuscleGroup.biceps,
      secondaryMuscleGroups: const [MuscleGroup.forearms],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 17. Cable Tricep Rope Pushdown (SMALL - Triceps - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000017',
      name: 'Cable Tricep Rope Pushdown',
      equipmentCategory: EquipmentCategory.cable,
      primaryMuscleGroup: MuscleGroup.triceps,
      secondaryMuscleGroups: const [],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 18. Standing Machine Calf Raise (SMALL - Calves - weight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000018',
      name: 'Standing Machine Calf Raise',
      equipmentCategory: EquipmentCategory.machine,
      primaryMuscleGroup: MuscleGroup.calves,
      secondaryMuscleGroups: const [],
      exerciseType: ExerciseType.weight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 19. Hanging Leg Raise (SMALL - Abs - bodyweight_reps)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000019',
      name: 'Hanging Leg Raise',
      equipmentCategory: EquipmentCategory.bodyweight,
      primaryMuscleGroup: MuscleGroup.abs,
      secondaryMuscleGroups: const [MuscleGroup.forearms],
      exerciseType: ExerciseType.bodyweight_reps,
      seedTimestamp: seedTimestamp,
    ),
    // 20. Plank (SMALL - Abs - duration)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000020',
      name: 'Plank',
      equipmentCategory: EquipmentCategory.bodyweight,
      primaryMuscleGroup: MuscleGroup.abs,
      secondaryMuscleGroups: const [MuscleGroup.front_delts],
      exerciseType: ExerciseType.duration,
      seedTimestamp: seedTimestamp,
    ),
    // 21. Weighted Plank (SMALL - Abs - duration_weight)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000021',
      name: 'Weighted Plank',
      equipmentCategory: EquipmentCategory.bodyweight,
      primaryMuscleGroup: MuscleGroup.abs,
      secondaryMuscleGroups: const [MuscleGroup.front_delts],
      exerciseType: ExerciseType.duration_weight,
      seedTimestamp: seedTimestamp,
    ),
    // 22. Farmer's Walk (SMALL - Forearms/Traps - weight_distance)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000022',
      name: "Farmer's Walk",
      equipmentCategory: EquipmentCategory.trap_bar,
      primaryMuscleGroup: MuscleGroup.forearms,
      secondaryMuscleGroups: const [
        MuscleGroup.traps,
        MuscleGroup.abs,
        MuscleGroup.calves,
      ],
      exerciseType: ExerciseType.weight_distance,
      seedTimestamp: seedTimestamp,
    ),
    // 23. Rowing Ergometer (LARGE - Upper Back - distance_duration)
    _seedExercise(
      id: '10000000-0000-4000-8000-000000000023',
      name: 'Rowing Ergometer',
      equipmentCategory: EquipmentCategory.machine,
      primaryMuscleGroup: MuscleGroup.upper_back,
      secondaryMuscleGroups: const [
        MuscleGroup.quads,
        MuscleGroup.hamstrings,
        MuscleGroup.lats,
      ],
      exerciseType: ExerciseType.distance_duration,
      seedTimestamp: seedTimestamp,
    ),
  ];

  await db.batch((batch) {
    batch.insertAll(
      db.exercises,
      builtInExercises,
      mode: InsertMode.insertOrIgnore,
    );
  });
}

ExercisesCompanion _seedExercise({
  required String id,
  required String name,
  required EquipmentCategory equipmentCategory,
  required MuscleGroup primaryMuscleGroup,
  required List<MuscleGroup> secondaryMuscleGroups,
  required ExerciseType exerciseType,
  required DateTime seedTimestamp,
}) {
  return ExercisesCompanion.insert(
    id: Value(id),
    createdAt: Value(seedTimestamp),
    updatedAt: Value(seedTimestamp),
    syncStatus: Value(SyncStatus.synced),
    name: name,
    equipmentCategory: equipmentCategory,
    primaryMuscleGroup: primaryMuscleGroup,
    secondaryMuscleGroups: Value(secondaryMuscleGroups),
    muscleSizeCategory: primaryMuscleGroup.defaultSizeCategory,
    exerciseType: exerciseType,
    isCustom: const Value(false),
  );
}
