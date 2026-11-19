import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../../core/media/media_compression_service.dart';
import '../data/exercise_library_repository.dart';

part 'exercise_library_providers.g.dart';

/// Immutable filter state for the Exercise Library screen.
class ExerciseFilterState {
  const ExerciseFilterState({
    this.searchQuery = '',
    this.primaryMuscleGroup,
    this.equipmentCategory,
    this.exerciseType,
  });

  final String searchQuery;
  final MuscleGroup? primaryMuscleGroup;
  final EquipmentCategory? equipmentCategory;
  final ExerciseType? exerciseType;

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      primaryMuscleGroup != null ||
      equipmentCategory != null ||
      exerciseType != null;

  ExerciseFilterState copyWith({
    String? searchQuery,
    MuscleGroup? Function()? primaryMuscleGroup,
    EquipmentCategory? Function()? equipmentCategory,
    ExerciseType? Function()? exerciseType,
  }) {
    return ExerciseFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      primaryMuscleGroup: primaryMuscleGroup != null
          ? primaryMuscleGroup()
          : this.primaryMuscleGroup,
      equipmentCategory: equipmentCategory != null
          ? equipmentCategory()
          : this.equipmentCategory,
      exerciseType: exerciseType != null ? exerciseType() : this.exerciseType,
    );
  }
}

@riverpod
class ExerciseFilterController extends _$ExerciseFilterController {
  @override
  ExerciseFilterState build() => const ExerciseFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setMuscleGroup(MuscleGroup? group) {
    state = state.copyWith(primaryMuscleGroup: () => group);
  }

  void setEquipmentCategory(EquipmentCategory? category) {
    state = state.copyWith(equipmentCategory: () => category);
  }

  void setExerciseType(ExerciseType? type) {
    state = state.copyWith(exerciseType: () => type);
  }

  void clearFilters() {
    state = const ExerciseFilterState();
  }
}

final filteredExercisesStreamProvider =
    StreamProvider.autoDispose<List<Exercise>>((ref) {
      final repo = ref.watch(exerciseLibraryRepositoryProvider);
      final filter = ref.watch(exerciseFilterControllerProvider);
      return repo.watchExercises(
        searchQuery: filter.searchQuery,
        primaryMuscleGroup: filter.primaryMuscleGroup,
        equipmentCategory: filter.equipmentCategory,
        exerciseType: filter.exerciseType,
      );
    });

final allExercisesStreamProvider = StreamProvider.autoDispose<List<Exercise>>((
  ref,
) {
  final repo = ref.watch(exerciseLibraryRepositoryProvider);
  return repo.watchExercises();
});

final exerciseDetailStreamProvider = StreamProvider.autoDispose
    .family<Exercise?, String>((ref, exerciseId) {
      final repo = ref.watch(exerciseLibraryRepositoryProvider);
      return repo.watchExerciseById(exerciseId);
    });

typedef ExerciseMediaScopeKey = ({String exerciseId, String? gymMachineId});

final exerciseMediaListProvider = StreamProvider.autoDispose
    .family<List<ExerciseMediaData>, ExerciseMediaScopeKey>((ref, key) {
      final repo = ref.watch(exerciseLibraryRepositoryProvider);
      return repo.watchMediaForExercise(
        key.exerciseId,
        gymMachineId: key.gymMachineId,
      );
    });

/// State representing ongoing photo/video compression for an exercise/machine.
class ExerciseMediaUploadState {
  const ExerciseMediaUploadState({
    this.isProcessing = false,
    this.activeMediaType,
    this.progress,
  });

  final bool isProcessing;
  final MediaType? activeMediaType;

  /// `0.0 - 1.0` during video transcoding, or `null` for indeterminate photo compression.
  final double? progress;
}

@riverpod
class ExerciseMediaController extends _$ExerciseMediaController {
  @override
  ExerciseMediaUploadState build(String exerciseId, [String? gymMachineId]) {
    return const ExerciseMediaUploadState();
  }

  Future<void> pickAndAddPhoto(ImageSource source) async {
    final repo = ref.read(exerciseLibraryRepositoryProvider);
    final compressionService = ref.read(mediaCompressionServiceProvider);

    // Check active photo count (max 4) for this specific machine/exercise
    await repo.ensureCanAddMedia(
      exerciseId: exerciseId,
      gymMachineId: gymMachineId,
      mediaType: MediaType.photo,
    );

    state = const ExerciseMediaUploadState(
      isProcessing: true,
      activeMediaType: MediaType.photo,
    );

    try {
      final result = await compressionService.compressAndSavePhoto(
        source: source,
      );
      if (result == null) return;

      await repo.addExerciseMedia(
        exerciseId: exerciseId,
        gymMachineId: gymMachineId,
        mediaType: MediaType.photo,
        localPath: result.localPath,
        fileSizeBytes: result.fileSizeBytes,
      );
    } finally {
      state = const ExerciseMediaUploadState();
    }
  }

  Future<void> pickAndAddVideo(ImageSource source) async {
    final repo = ref.read(exerciseLibraryRepositoryProvider);
    final compressionService = ref.read(mediaCompressionServiceProvider);

    // Check active video count (max 3) for this specific machine/exercise
    await repo.ensureCanAddMedia(
      exerciseId: exerciseId,
      gymMachineId: gymMachineId,
      mediaType: MediaType.video,
    );

    state = const ExerciseMediaUploadState(
      isProcessing: true,
      activeMediaType: MediaType.video,
      progress: 0.0,
    );

    try {
      final result = await compressionService.compressAndSaveVideo(
        source: source,
        onProgress: (progress) {
          state = ExerciseMediaUploadState(
            isProcessing: true,
            activeMediaType: MediaType.video,
            progress: progress,
          );
        },
      );
      if (result == null) return;

      await repo.addExerciseMedia(
        exerciseId: exerciseId,
        gymMachineId: gymMachineId,
        mediaType: MediaType.video,
        localPath: result.localPath,
        thumbnailLocalPath: result.thumbnailLocalPath,
        fileSizeBytes: result.fileSizeBytes,
        durationSeconds: result.durationSeconds,
      );
    } finally {
      state = const ExerciseMediaUploadState();
    }
  }

  Future<void> deleteMedia(String mediaId) async {
    final repo = ref.read(exerciseLibraryRepositoryProvider);
    await repo.softDeleteExerciseMedia(mediaId);
  }
}
