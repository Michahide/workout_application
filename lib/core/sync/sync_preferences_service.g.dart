// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_preferences_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncPreferencesService)
final syncPreferencesServiceProvider = SyncPreferencesServiceProvider._();

final class SyncPreferencesServiceProvider
    extends
        $FunctionalProvider<
          SyncPreferencesService,
          SyncPreferencesService,
          SyncPreferencesService
        >
    with $Provider<SyncPreferencesService> {
  SyncPreferencesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncPreferencesServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncPreferencesServiceHash();

  @$internal
  @override
  $ProviderElement<SyncPreferencesService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SyncPreferencesService create(Ref ref) {
    return syncPreferencesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncPreferencesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncPreferencesService>(value),
    );
  }
}

String _$syncPreferencesServiceHash() =>
    r'b086a8e3bc30b3c4a60bcf2835128a9bf5d6b742';
