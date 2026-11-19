import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/syncable_table_mixin.dart';
import '../database/tables.dart';

part 'hevy_csv_import_service.g.dart';

/// Exception thrown when a Hevy CSV file cannot be parsed or imported.
class HevyCsvImportException implements Exception {
  const HevyCsvImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Summary statistics returned after importing a Hevy `.csv` workout export.
class HevyImportResult {
  const HevyImportResult({
    required this.importedSessionsCount,
    required this.skippedDuplicateSessionsCount,
    required this.importedSetsCount,
    required this.createdExercisesCount,
    required this.createdMachinesCount,
    required this.createdPlansCount,
  });

  final int importedSessionsCount;
  final int skippedDuplicateSessionsCount;
  final int importedSetsCount;
  final int createdExercisesCount;
  final int createdMachinesCount;
  final int createdPlansCount;
}

/// Internal parsed row from a Hevy CSV file.
class _HevySetRow {
  const _HevySetRow({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.exerciseTitle,
    this.supersetId,
    required this.exerciseNotes,
    required this.setIndex,
    required this.setType,
    this.weightKg,
    this.reps,
    this.distanceMeters,
    this.durationSeconds,
    this.rpe,
  });

  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final String exerciseTitle;
  final String? supersetId;
  final String exerciseNotes;
  final int setIndex;
  final SetType setType;
  final double? weightKg;
  final int? reps;
  final double? distanceMeters;
  final int? durationSeconds;
  final double? rpe;
}

/// Service that parses and imports workout history, exercises, machines, and routines
/// from a Hevy CSV export (`workout_data.csv`).
class HevyCsvImportService {
  HevyCsvImportService(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();
  static final DateFormat _hevyDateFormat = DateFormat(
    'd MMM yyyy, HH:mm',
    'en_US',
  );

  /// Opens the native file picker for a Hevy `.csv` file and imports it into [gymLocationId].
  /// Returns `null` if the user cancels the file picker.
  Future<HevyImportResult?> pickAndImportHevyCsv({
    String? gymLocationId,
  }) async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Pilih File CSV Export dari Hevy',
      type: FileType.any,
    );

    if (picked == null) {
      return null;
    }

    final bytes = await picked.readAsBytes();
    String csvContent;
    try {
      csvContent = utf8.decode(bytes);
    } on FormatException {
      csvContent = latin1.decode(bytes);
    }

    return importFromCsvString(
      csvContent,
      gymLocationId: gymLocationId,
    );
  }

  /// Imports the bundled `workout_data.csv` asset directly into [gymLocationId].
  Future<HevyImportResult> importBundledWorkoutDataCsv({
    String? gymLocationId,
  }) async {
    final csvContent = await rootBundle.loadString('workout_data.csv');
    return importFromCsvString(
      csvContent,
      gymLocationId: gymLocationId,
    );
  }

  /// Imports a Hevy CSV file from a local [filePath].
  Future<HevyImportResult> importFromFilePath(
    String filePath, {
    String? gymLocationId,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const HevyCsvImportException('File CSV tidak ditemukan.');
    }
    final content = await file.readAsString();
    return importFromCsvString(content, gymLocationId: gymLocationId);
  }

  /// Parses [csvContent] in Hevy CSV format and imports all sessions, exercises,
  /// gym machines, workout plans, and sets inside a Drift transaction.
  Future<HevyImportResult> importFromCsvString(
    String csvContent, {
    String? gymLocationId,
  }) async {
    final rawTable = parseCsvTable(csvContent);
    if (rawTable.length < 2) {
      throw const HevyCsvImportException(
        'File CSV kosong atau tidak memiliki baris data.',
      );
    }

    final header = rawTable.first
        .map((h) => h.trim().toLowerCase().replaceAll('\ufeff', ''))
        .toList(growable: false);

    final colMap = <String, int>{
      for (var i = 0; i < header.length; i++) header[i]: i,
    };

    if (!colMap.containsKey('title') ||
        !colMap.containsKey('start_time') ||
        !colMap.containsKey('exercise_title')) {
      throw const HevyCsvImportException(
        'Format header CSV tidak sesuai dengan export aplikasi Hevy '
        '(wajib memiliki kolom title, start_time, exercise_title).',
      );
    }

    final parsedRows = <_HevySetRow>[];
    for (var rowIdx = 1; rowIdx < rawTable.length; rowIdx++) {
      final row = rawTable[rowIdx];
      if (row.isEmpty || row.every((cell) => cell.trim().isEmpty)) {
        continue;
      }

      String cell(String name) {
        final idx = colMap[name];
        if (idx == null || idx >= row.length) return '';
        return row[idx].trim();
      }

      final title = cell('title').isEmpty ? 'Hevy Workout' : cell('title');
      final exerciseTitle = cell('exercise_title');
      if (exerciseTitle.isEmpty) continue;

      final startDt = _parseHevyDateTime(cell('start_time'));
      if (startDt == null) continue;
      final endDt = _parseHevyDateTime(cell('end_time')) ??
          startDt.add(const Duration(hours: 1));

      final setIdx = int.tryParse(cell('set_index')) ?? 0;
      final setType = _parseHevySetType(cell('set_type'));

      double? weightKg = double.tryParse(cell('weight_kg'));
      if (weightKg == null && colMap.containsKey('weight_lbs')) {
        final lbs = double.tryParse(cell('weight_lbs'));
        if (lbs != null) weightKg = lbs * 0.45359237;
      }

      final reps = int.tryParse(cell('reps'));
      final distanceKm = double.tryParse(cell('distance_km'));
      final distanceMeters = distanceKm != null ? distanceKm * 1000.0 : null;
      final durationSeconds = int.tryParse(cell('duration_seconds'));
      final rpe = double.tryParse(cell('rpe'));
      final supersetRaw = cell('superset_id');

      parsedRows.add(
        _HevySetRow(
          title: title,
          startTime: startDt,
          endTime: endDt,
          description: cell('description'),
          exerciseTitle: exerciseTitle,
          supersetId: supersetRaw.isEmpty ? null : 'ss_hevy_$supersetRaw',
          exerciseNotes: cell('exercise_notes'),
          setIndex: setIdx,
          setType: setType,
          weightKg: weightKg,
          reps: reps,
          distanceMeters: distanceMeters,
          durationSeconds: durationSeconds,
          rpe: rpe,
        ),
      );
    }

    if (parsedRows.isEmpty) {
      throw const HevyCsvImportException(
        'Tidak ada baris set latihan yang valid untuk di-import.',
      );
    }

    // Group rows by unique session key: (title, startTime.toIso8601String())
    final sessionsMap = <String, List<_HevySetRow>>{};
    for (final r in parsedRows) {
      final sessionKey = '${r.title}::${r.startTime.toUtc().toIso8601String()}';
      sessionsMap.putIfAbsent(sessionKey, () => []).add(r);
    }

    var importedSessionsCount = 0;
    var skippedDuplicateSessionsCount = 0;
    var importedSetsCount = 0;
    var createdExercisesCount = 0;
    var createdMachinesCount = 0;
    var createdPlansCount = 0;

    final now = DateTime.now().toUtc();

    await _db.transaction(() async {
      // 1. Ensure target Gym Location exists
      String resolvedGymId;
      if (gymLocationId != null && gymLocationId.isNotEmpty) {
        resolvedGymId = gymLocationId;
      } else {
        final existingGyms = await (_db.select(_db.gymLocations)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .get();
        if (existingGyms.isNotEmpty) {
          resolvedGymId = existingGyms.first.id;
        } else {
          resolvedGymId = _uuid.v4();
          await _db.into(_db.gymLocations).insert(
                GymLocationsCompanion.insert(
                  id: Value(resolvedGymId),
                  name: 'Main Gym (Hevy)',
                  notes: const Value('Di-import dari aplikasi Hevy'),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                  syncStatus: Value(SyncStatus.pendingPush),
                ),
              );
        }
      }

      // 2. Load existing exercises, machines, plans, and sessions for fast lookup
      final existingExercises = await (_db.select(_db.exercises)
            ..where((t) => t.deletedAt.isNull()))
          .get();
      final exerciseByNormalizedName = <String, Exercise>{
        for (final ex in existingExercises) _normalizeName(ex.name): ex,
      };

      final existingMachines = await (_db.select(_db.gymMachines)
            ..where(
              (t) =>
                  t.gymLocationId.equals(resolvedGymId) & t.deletedAt.isNull(),
            ))
          .get();
      final machineByExerciseId = <String, GymMachine>{
        for (final m in existingMachines) m.exerciseId: m,
      };

      final existingPlans = await (_db.select(_db.workoutPlans)
            ..where((t) => t.deletedAt.isNull()))
          .get();
      final planIdByNormalizedName = <String, String>{
        for (final p in existingPlans) _normalizeName(p.name): p.id,
      };

      final existingSessions = await (_db.select(_db.workoutSessions)
            ..where((t) => t.deletedAt.isNull()))
          .get();
      final existingSessionStartMillis = <int>{
        for (final s in existingSessions)
          s.startedAt.toUtc().millisecondsSinceEpoch,
      };

      // Track the most recent exercise list for each Workout Plan title to seed WorkoutPlanExercises
      final latestSessionRowsByPlanTitle = <String, List<_HevySetRow>>{};

      // Process sessions in chronological order (oldest to newest)
      final sortedSessionEntries = sessionsMap.entries.toList()
        ..sort(
          (a, b) => a.value.first.startTime.compareTo(b.value.first.startTime),
        );

      for (final entry in sortedSessionEntries) {
        final sessionRows = entry.value;
        final firstRow = sessionRows.first;
        final startUtc = firstRow.startTime.toUtc();
        final endUtc = firstRow.endTime.toUtc();

        // Duplicate check by startedAt timestamp
        if (existingSessionStartMillis.contains(
          startUtc.millisecondsSinceEpoch,
        )) {
          skippedDuplicateSessionsCount++;
          continue;
        }
        existingSessionStartMillis.add(startUtc.millisecondsSinceEpoch);

        // Resolve or create WorkoutPlan for this session title
        final normPlanTitle = _normalizeName(firstRow.title);
        var planId = planIdByNormalizedName[normPlanTitle];
        if (planId == null) {
          planId = _uuid.v4();
          await _db.into(_db.workoutPlans).insert(
                WorkoutPlansCompanion.insert(
                  id: Value(planId),
                  name: firstRow.title,
                  notes: const Value('Rutinitas di-import dari Hevy'),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                  syncStatus: Value(SyncStatus.pendingPush),
                ),
              );
          planIdByNormalizedName[normPlanTitle] = planId;
          createdPlansCount++;
        }
        latestSessionRowsByPlanTitle[normPlanTitle] = sessionRows;

        // Create WorkoutSession
        final sessionId = _uuid.v4();
        await _db.into(_db.workoutSessions).insert(
              WorkoutSessionsCompanion.insert(
                id: Value(sessionId),
                workoutPlanId: Value(planId),
                gymLocationId: Value(resolvedGymId),
                startedAt: startUtc,
                completedAt: Value(endUtc),
                sessionNotes: Value(
                  firstRow.description.isEmpty ? null : firstRow.description,
                ),
                createdAt: Value(startUtc),
                updatedAt: Value(now),
                syncStatus: Value(SyncStatus.pendingPush),
              ),
            );
        importedSessionsCount++;

        // Group session rows by exercise preserving order of appearance
        final exerciseOrder = <String>[];
        final rowsByExerciseTitle = <String, List<_HevySetRow>>{};
        for (final r in sessionRows) {
          if (!rowsByExerciseTitle.containsKey(r.exerciseTitle)) {
            exerciseOrder.add(r.exerciseTitle);
            rowsByExerciseTitle[r.exerciseTitle] = [];
          }
          rowsByExerciseTitle[r.exerciseTitle]!.add(r);
        }

        for (var exOrderIdx = 0;
            exOrderIdx < exerciseOrder.length;
            exOrderIdx++) {
          final exTitle = exerciseOrder[exOrderIdx];
          final exRows = rowsByExerciseTitle[exTitle]!;
          final normExName = _normalizeName(exTitle);

          // Resolve or create Exercise
          var exercise = exerciseByNormalizedName[normExName];
          if (exercise == null) {
            final inferred = _inferExerciseAttributes(exTitle, exRows);
            final newExId = _uuid.v4();
            exercise = Exercise(
              id: newExId,
              createdAt: now,
              updatedAt: now,
              deletedAt: null,
              syncStatus: SyncStatus.pendingPush,
              name: exTitle,
              equipmentCategory: inferred.equipment,
              primaryMuscleGroup: inferred.primaryMuscle,
              secondaryMuscleGroups: inferred.secondaryMuscles,
              muscleSizeCategory: inferred.primaryMuscle.defaultSizeCategory,
              exerciseType: inferred.exerciseType,
              defaultWorkingRestSeconds: null,
              isCustom: true,
            );
            await _db.into(_db.exercises).insert(
                  ExercisesCompanion.insert(
                    id: Value(exercise.id),
                    name: exercise.name,
                    equipmentCategory: exercise.equipmentCategory,
                    primaryMuscleGroup: exercise.primaryMuscleGroup,
                    secondaryMuscleGroups: Value(
                      exercise.secondaryMuscleGroups,
                    ),
                    muscleSizeCategory: exercise.muscleSizeCategory,
                    exerciseType: exercise.exerciseType,
                    isCustom: const Value(true),
                    createdAt: Value(now),
                    updatedAt: Value(now),
                    syncStatus: Value(SyncStatus.pendingPush),
                  ),
                );
            exerciseByNormalizedName[normExName] = exercise;
            createdExercisesCount++;
          }

          // Resolve or create GymMachine for (resolvedGymId, exercise.id)
          var machine = machineByExerciseId[exercise.id];
          final nonEmptyNote = exRows
              .map((r) => r.exerciseNotes)
              .where((n) => n.isNotEmpty)
              .firstOrNull;

          if (machine == null) {
            final newMachineId = _uuid.v4();
            final brandLabel = _extractMachineLabel(
              exTitle,
              exercise.equipmentCategory,
            );
            machine = GymMachine(
              id: newMachineId,
              createdAt: now,
              updatedAt: now,
              deletedAt: null,
              syncStatus: SyncStatus.pendingPush,
              gymLocationId: resolvedGymId,
              exerciseId: exercise.id,
              brandName: brandLabel,
              weightUnit: WeightUnit.KG,
              pinnedNotes: nonEmptyNote,
            );
            await _db.into(_db.gymMachines).insert(
                  GymMachinesCompanion.insert(
                    id: Value(machine.id),
                    gymLocationId: Value(resolvedGymId),
                    exerciseId: exercise.id,
                    brandName: Value(machine.brandName),
                    weightUnit: const Value(WeightUnit.KG),
                    pinnedNotes: Value(nonEmptyNote),
                    createdAt: Value(now),
                    updatedAt: Value(now),
                    syncStatus: Value(SyncStatus.pendingPush),
                  ),
                );
            machineByExerciseId[exercise.id] = machine;
            createdMachinesCount++;
          } else if (nonEmptyNote != null &&
              (machine.pinnedNotes == null || machine.pinnedNotes!.isEmpty)) {
            await (_db.update(_db.gymMachines)
                  ..where((t) => t.id.equals(machine!.id)))
                .write(
              GymMachinesCompanion(
                pinnedNotes: Value(nonEmptyNote),
                updatedAt: Value(now),
                syncStatus: Value(SyncStatus.pendingPush),
              ),
            );
          }

          // Create WorkoutSessionExercise
          final seId = _uuid.v4();
          await _db.into(_db.workoutSessionExercises).insert(
                WorkoutSessionExercisesCompanion.insert(
                  id: Value(seId),
                  workoutSessionId: sessionId,
                  exerciseId: exercise.id,
                  gymMachineId: Value(machine.id),
                  sortOrder: Value(exOrderIdx),
                  supersetGroupId: Value(exRows.first.supersetId),
                  createdAt: Value(startUtc),
                  updatedAt: Value(now),
                  syncStatus: Value(SyncStatus.pendingPush),
                ),
              );

          // Insert all completed sets for this exercise
          for (var i = 0; i < exRows.length; i++) {
            final r = exRows[i];
            final setNum = i + 1;
            await _db.into(_db.workoutSets).insert(
                  WorkoutSetsCompanion.insert(
                    id: Value(_uuid.v4()),
                    workoutSessionExerciseId: seId,
                    setNumber: setNum,
                    setType: Value(r.setType),
                    weight: Value(r.weightKg),
                    reps: Value(r.reps),
                    durationSeconds: Value(r.durationSeconds),
                    distanceMeters: Value(r.distanceMeters),
                    rpe: Value(r.rpe),
                    assistanceType: const Value(AssistanceType.solo),
                    isCompleted: const Value(true),
                    completedAt: Value(endUtc),
                    createdAt: Value(startUtc),
                    updatedAt: Value(now),
                    syncStatus: Value(SyncStatus.pendingPush),
                  ),
                );
            importedSetsCount++;
          }
        }
      }

      // 3. Populate WorkoutPlanExercises for newly created plans that don't have exercises yet
      for (final entry in latestSessionRowsByPlanTitle.entries) {
        final planId = planIdByNormalizedName[entry.key];
        if (planId == null) continue;

        final existingPlanExercises = await (_db.select(_db.workoutPlanExercises)
              ..where(
                (t) =>
                    t.workoutPlanId.equals(planId) & t.deletedAt.isNull(),
              ))
            .get();
        if (existingPlanExercises.isNotEmpty) continue;

        final sessionRows = entry.value;
        final orderedTitles = <String>[];
        final grouped = <String, List<_HevySetRow>>{};
        for (final r in sessionRows) {
          if (!grouped.containsKey(r.exerciseTitle)) {
            orderedTitles.add(r.exerciseTitle);
            grouped[r.exerciseTitle] = [];
          }
          grouped[r.exerciseTitle]!.add(r);
        }

        for (var idx = 0; idx < orderedTitles.length; idx++) {
          final exTitle = orderedTitles[idx];
          final rows = grouped[exTitle]!;
          final exercise = exerciseByNormalizedName[_normalizeName(exTitle)];
          if (exercise == null) continue;

          final workingRows = rows
              .where((r) => r.setType != SetType.warmup)
              .toList(growable: false);
          final targetSetsCount =
              (workingRows.isNotEmpty ? workingRows.length : rows.length)
                  .clamp(1, 20);
          final targetRepsVal =
              (workingRows.isNotEmpty ? workingRows.first.reps : rows.first.reps);
          final machine = machineByExerciseId[exercise.id];

          await _db.into(_db.workoutPlanExercises).insert(
                WorkoutPlanExercisesCompanion.insert(
                  id: Value(_uuid.v4()),
                  workoutPlanId: planId,
                  exerciseId: exercise.id,
                  defaultGymMachineId: Value(machine?.id),
                  sortOrder: idx,
                  supersetGroupId: Value(rows.first.supersetId),
                  targetSets: Value(targetSetsCount),
                  targetReps: Value(targetRepsVal),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                  syncStatus: Value(SyncStatus.pendingPush),
                ),
              );
        }
      }
    });

    return HevyImportResult(
      importedSessionsCount: importedSessionsCount,
      skippedDuplicateSessionsCount: skippedDuplicateSessionsCount,
      importedSetsCount: importedSetsCount,
      createdExercisesCount: createdExercisesCount,
      createdMachinesCount: createdMachinesCount,
      createdPlansCount: createdPlansCount,
    );
  }

  // ---------------------------------------------------------------------------
  // RFC-4180 CSV PARSER & HEVY INFERENCE HELPERS
  // ---------------------------------------------------------------------------

  /// Parses an RFC-4180 CSV string into rows of fields, properly handling
  /// commas inside double quotes (e.g. `"18 Nov 2026, 18:49"`) and escaped quotes `""`.
  static List<List<String>> parseCsvTable(String input) {
    final rows = <List<String>>[];
    var currentRow = <String>[];
    final currentCell = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];

      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < input.length && input[i + 1] == '"') {
            currentCell.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          currentCell.write(char);
        }
      } else {
        if (char == '"') {
          inQuotes = true;
        } else if (char == ',') {
          currentRow.add(currentCell.toString());
          currentCell.clear();
        } else if (char == '\r') {
          if (i + 1 < input.length && input[i + 1] == '\n') {
            i++;
          }
          currentRow.add(currentCell.toString());
          currentCell.clear();
          rows.add(currentRow);
          currentRow = <String>[];
        } else if (char == '\n') {
          currentRow.add(currentCell.toString());
          currentCell.clear();
          rows.add(currentRow);
          currentRow = <String>[];
        } else {
          currentCell.write(char);
        }
      }
    }

    if (currentCell.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentCell.toString());
      rows.add(currentRow);
    }

    return rows;
  }

  DateTime? _parseHevyDateTime(String raw) {
    if (raw.isEmpty) return null;
    try {
      return _hevyDateFormat.parse(raw);
    } catch (_) {
      return DateTime.tryParse(raw);
    }
  }

  SetType _parseHevySetType(String raw) {
    return switch (raw.toLowerCase()) {
      'warmup' => SetType.warmup,
      'dropset' => SetType.dropset,
      'failure' => SetType.failure,
      _ => SetType.normal,
    };
  }

  String _normalizeName(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  String _extractMachineLabel(String exerciseTitle, EquipmentCategory category) {
    final parenMatch = RegExp(r'\(([^)]+)\)').firstMatch(exerciseTitle);
    if (parenMatch != null) {
      return 'Hevy ${parenMatch.group(1)!}';
    }
    return switch (category) {
      EquipmentCategory.machine => 'Hevy Machine',
      EquipmentCategory.cable => 'Hevy Cable',
      EquipmentCategory.barbell => 'Standard Barbell',
      EquipmentCategory.dumbbell => 'Dumbbell Set',
      EquipmentCategory.bodyweight => 'Bodyweight',
      EquipmentCategory.smith_machine => 'Smith Machine',
      EquipmentCategory.trap_bar => 'Trap Bar',
      EquipmentCategory.kettlebell => 'Kettlebell',
      EquipmentCategory.band => 'Resistance Band',
      EquipmentCategory.other => 'Standard Equipment',
    };
  }

  ({
    EquipmentCategory equipment,
    MuscleGroup primaryMuscle,
    List<MuscleGroup> secondaryMuscles,
    ExerciseType exerciseType,
  }) _inferExerciseAttributes(String title, List<_HevySetRow> sampleRows) {
    final lower = title.toLowerCase();

    // 1. Infer EquipmentCategory
    final EquipmentCategory equipment;
    if (lower.contains('(machine') ||
        lower.contains('machine') ||
        lower.contains('leg press') ||
        lower.contains('leg extension') ||
        lower.contains('leg curl') ||
        lower.contains('abduction') ||
        lower.contains('adduction') ||
        lower.contains('chest press')) {
      equipment = EquipmentCategory.machine;
    } else if (lower.contains('(cable)') ||
        lower.contains('cable') ||
        lower.contains('pushdown') ||
        lower.contains('face pull') ||
        lower.contains('pulldown')) {
      equipment = EquipmentCategory.cable;
    } else if (lower.contains('(dumbbell)') ||
        lower.contains('dumbbell') ||
        lower.contains('hammer curl')) {
      equipment = EquipmentCategory.dumbbell;
    } else if (lower.contains('(barbell)') ||
        lower.contains('barbell') ||
        lower.contains('deadlift')) {
      equipment = EquipmentCategory.barbell;
    } else if (lower.contains('smith')) {
      equipment = EquipmentCategory.smith_machine;
    } else if (lower.contains('plank') ||
        lower.contains('push-up') ||
        lower.contains('pull-up') ||
        lower.contains('chin-up')) {
      equipment = EquipmentCategory.bodyweight;
    } else {
      equipment = EquipmentCategory.other;
    }

    // 2. Infer Primary & Secondary MuscleGroup
    MuscleGroup primary = MuscleGroup.chest;
    List<MuscleGroup> secondary = const [];

    if (lower.contains('bench press') ||
        lower.contains('chest press') ||
        lower.contains('chest fly') ||
        lower.contains('pec')) {
      primary = MuscleGroup.chest;
      secondary = const [MuscleGroup.front_delts, MuscleGroup.triceps];
    } else if (lower.contains('lat pulldown') ||
        lower.contains('pull-up') ||
        lower.contains('chin-up')) {
      primary = MuscleGroup.lats;
      secondary = const [MuscleGroup.biceps, MuscleGroup.upper_back];
    } else if (lower.contains('rear delt') ||
        lower.contains('reverse fly') ||
        lower.contains('face pull')) {
      primary = MuscleGroup.rear_delts;
      secondary = const [MuscleGroup.upper_back, MuscleGroup.traps];
    } else if (lower.contains('lateral raise') ||
        lower.contains('upright row')) {
      primary = MuscleGroup.side_delts;
      secondary = const [MuscleGroup.traps];
    } else if (lower.contains('shoulder press') ||
        lower.contains('overhead press') ||
        lower.contains('front raise')) {
      primary = MuscleGroup.front_delts;
      secondary = const [MuscleGroup.side_delts, MuscleGroup.triceps];
    } else if (lower.contains('shrug')) {
      primary = MuscleGroup.traps;
      secondary = const [MuscleGroup.forearms, MuscleGroup.upper_back];
    } else if (lower.contains('leg curl') ||
        lower.contains('romanian') ||
        lower.contains('hamstring')) {
      primary = MuscleGroup.hamstrings;
      secondary = const [MuscleGroup.glutes, MuscleGroup.calves];
    } else if (lower.contains('deadlift') || lower.contains('row')) {
      primary = MuscleGroup.upper_back;
      secondary = const [
        MuscleGroup.lats,
        MuscleGroup.biceps,
        MuscleGroup.hamstrings,
      ];
    } else if (lower.contains('curl')) {
      primary = MuscleGroup.biceps;
      secondary = const [MuscleGroup.forearms];
    } else if (lower.contains('tricep') || lower.contains('pushdown')) {
      primary = MuscleGroup.triceps;
      secondary = const [];
    } else if (lower.contains('leg press') ||
        lower.contains('leg extension') ||
        lower.contains('squat') ||
        lower.contains('lunge')) {
      primary = MuscleGroup.quads;
      secondary = const [MuscleGroup.glutes, MuscleGroup.hamstrings];
    } else if (lower.contains('hip thrust') ||
        lower.contains('abduction') ||
        lower.contains('adduction') ||
        lower.contains('glute')) {
      primary = MuscleGroup.glutes;
      secondary = const [MuscleGroup.hamstrings, MuscleGroup.quads];
    } else if (lower.contains('calf')) {
      primary = MuscleGroup.calves;
      secondary = const [];
    } else if (lower.contains('plank') ||
        lower.contains('ab') ||
        lower.contains('crunch')) {
      primary = MuscleGroup.abs;
      secondary = const [];
    }

    // 3. Infer ExerciseType from sample rows
    final hasWeight = sampleRows.any((r) => (r.weightKg ?? 0) > 0);
    final hasReps = sampleRows.any((r) => (r.reps ?? 0) > 0);
    final hasDuration = sampleRows.any((r) => (r.durationSeconds ?? 0) > 0);
    final hasDistance = sampleRows.any((r) => (r.distanceMeters ?? 0) > 0);

    final ExerciseType exType;
    if (lower.contains('assisted')) {
      exType = ExerciseType.assisted_bodyweight;
    } else if (hasDuration && !hasWeight && !hasDistance) {
      exType = ExerciseType.duration;
    } else if (hasDuration && hasWeight) {
      exType = ExerciseType.duration_weight;
    } else if (hasDistance && hasDuration) {
      exType = ExerciseType.distance_duration;
    } else if (hasDistance && hasWeight) {
      exType = ExerciseType.weight_distance;
    } else if (!hasWeight && hasReps) {
      exType = ExerciseType.bodyweight_reps;
    } else {
      exType = ExerciseType.weight_reps;
    }

    return (
      equipment: equipment,
      primaryMuscle: primary,
      secondaryMuscles: secondary,
      exerciseType: exType,
    );
  }
}

@Riverpod(keepAlive: true)
HevyCsvImportService hevyCsvImportService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return HevyCsvImportService(db);
}
