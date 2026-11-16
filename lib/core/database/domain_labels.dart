import 'tables.dart';

extension WeightUnitLabelX on WeightUnit {
  String get label => switch (this) {
        WeightUnit.KG => 'KG',
        WeightUnit.LBS => 'LBS',
        WeightUnit.STACK_NUMBER => 'STACK #',
      };

  String get fullDescription => switch (this) {
        WeightUnit.KG => 'Kilogram (kg)',
        WeightUnit.LBS => 'Pounds (lbs)',
        WeightUnit.STACK_NUMBER => 'Nomor Tumpukan (Stack #)',
      };
}

extension EquipmentCategoryLabelX on EquipmentCategory {
  String get label => switch (this) {
        EquipmentCategory.machine => 'Machine',
        EquipmentCategory.cable => 'Cable',
        EquipmentCategory.barbell => 'Barbell',
        EquipmentCategory.dumbbell => 'Dumbbell',
        EquipmentCategory.bodyweight => 'Bodyweight',
        EquipmentCategory.smith_machine => 'Smith Machine',
        EquipmentCategory.trap_bar => 'Trap Bar',
        EquipmentCategory.kettlebell => 'Kettlebell',
        EquipmentCategory.band => 'Resistance Band',
        EquipmentCategory.other => 'Other',
      };
}

extension MuscleSizeCategoryLabelX on MuscleSizeCategory {
  String get label => switch (this) {
        MuscleSizeCategory.LARGE => 'LARGE (Otot Besar)',
        MuscleSizeCategory.SMALL => 'SMALL (Otot Kecil)',
      };

  String get shortLabel => switch (this) {
        MuscleSizeCategory.LARGE => 'LARGE',
        MuscleSizeCategory.SMALL => 'SMALL',
      };
}

extension MuscleGroupLabelX on MuscleGroup {
  String get label => switch (this) {
        MuscleGroup.chest => 'Chest',
        MuscleGroup.lats => 'Lats',
        MuscleGroup.upper_back => 'Upper Back',
        MuscleGroup.quads => 'Quads',
        MuscleGroup.hamstrings => 'Hamstrings',
        MuscleGroup.glutes => 'Glutes',
        MuscleGroup.front_delts => 'Front Delts',
        MuscleGroup.side_delts => 'Side Delts',
        MuscleGroup.rear_delts => 'Rear Delts',
        MuscleGroup.biceps => 'Biceps',
        MuscleGroup.triceps => 'Triceps',
        MuscleGroup.calves => 'Calves',
        MuscleGroup.abs => 'Abs',
        MuscleGroup.forearms => 'Forearms',
        MuscleGroup.traps => 'Traps',
      };
}

extension ExerciseTypeLabelX on ExerciseType {
  String get label => switch (this) {
        ExerciseType.weight_reps => 'Weight & Reps',
        ExerciseType.bodyweight_reps => 'Bodyweight Reps',
        ExerciseType.weighted_bodyweight => 'Weighted Bodyweight',
        ExerciseType.assisted_bodyweight => 'Assisted Bodyweight',
        ExerciseType.duration => 'Duration',
        ExerciseType.duration_weight => 'Duration & Weight',
        ExerciseType.distance_duration => 'Distance & Duration',
        ExerciseType.weight_distance => 'Weight & Distance',
      };

  String get description => switch (this) {
        ExerciseType.weight_reps => 'Beban eksternal × repetisi (contoh: Bench Press)',
        ExerciseType.bodyweight_reps =>
          'Berat badan × repetisi (contoh: Push-Up)',
        ExerciseType.weighted_bodyweight =>
          'Berat badan + beban tambahan (contoh: Weighted Dip)',
        ExerciseType.assisted_bodyweight =>
          'Berat badan − bantuan beban (makin kecil bantuan = progres)',
        ExerciseType.duration => 'Durasi waktu dalam detik (contoh: Plank)',
        ExerciseType.duration_weight =>
          'Durasi waktu + beban (contoh: Weighted Plank)',
        ExerciseType.distance_duration =>
          'Jarak (meter) & waktu (contoh: Rowing / Treadmill)',
        ExerciseType.weight_distance =>
          'Beban & jarak tempuh (contoh: Farmer\'s Walk)',
      };
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(2)} MB';
}
