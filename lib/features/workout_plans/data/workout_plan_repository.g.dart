// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workoutPlanRepository)
final workoutPlanRepositoryProvider = WorkoutPlanRepositoryProvider._();

final class WorkoutPlanRepositoryProvider
    extends
        $FunctionalProvider<
          WorkoutPlanRepository,
          WorkoutPlanRepository,
          WorkoutPlanRepository
        >
    with $Provider<WorkoutPlanRepository> {
  WorkoutPlanRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutPlanRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutPlanRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkoutPlanRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkoutPlanRepository create(Ref ref) {
    return workoutPlanRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutPlanRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutPlanRepository>(value),
    );
  }
}

String _$workoutPlanRepositoryHash() =>
    r'af14d38371904d9cb3a624d074bb7c9c4be25983';
