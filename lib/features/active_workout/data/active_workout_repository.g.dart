// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_workout_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activeWorkoutRepository)
final activeWorkoutRepositoryProvider = ActiveWorkoutRepositoryProvider._();

final class ActiveWorkoutRepositoryProvider
    extends
        $FunctionalProvider<
          ActiveWorkoutRepository,
          ActiveWorkoutRepository,
          ActiveWorkoutRepository
        >
    with $Provider<ActiveWorkoutRepository> {
  ActiveWorkoutRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeWorkoutRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeWorkoutRepositoryHash();

  @$internal
  @override
  $ProviderElement<ActiveWorkoutRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ActiveWorkoutRepository create(Ref ref) {
    return activeWorkoutRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActiveWorkoutRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActiveWorkoutRepository>(value),
    );
  }
}

String _$activeWorkoutRepositoryHash() =>
    r'd0459e5f2a2e604cee68d946c9242bf8b1a3f190';
