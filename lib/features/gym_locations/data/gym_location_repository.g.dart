// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_location_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gymLocationRepository)
final gymLocationRepositoryProvider = GymLocationRepositoryProvider._();

final class GymLocationRepositoryProvider
    extends
        $FunctionalProvider<
          GymLocationRepository,
          GymLocationRepository,
          GymLocationRepository
        >
    with $Provider<GymLocationRepository> {
  GymLocationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gymLocationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gymLocationRepositoryHash();

  @$internal
  @override
  $ProviderElement<GymLocationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GymLocationRepository create(Ref ref) {
    return gymLocationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GymLocationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GymLocationRepository>(value),
    );
  }
}

String _$gymLocationRepositoryHash() =>
    r'3a5f8b41e5427e3a30102a494afe22a320950a3e';
