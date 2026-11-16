// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_engine.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncEngine)
final syncEngineProvider = SyncEngineProvider._();

final class SyncEngineProvider
    extends $FunctionalProvider<SyncEngine, SyncEngine, SyncEngine>
    with $Provider<SyncEngine> {
  SyncEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncEngineHash();

  @$internal
  @override
  $ProviderElement<SyncEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncEngine create(Ref ref) {
    return syncEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncEngine>(value),
    );
  }
}

String _$syncEngineHash() => r'87560bfec5c77502004b6772e39defcb61bbcebd';

/// Riverpod controller managing [SyncEngineState], auto-sync on app startup,
/// auto-sync when connectivity recovers (`none` -> `wifi`/`mobile`), and manual sync.

@ProviderFor(SyncController)
final syncControllerProvider = SyncControllerProvider._();

/// Riverpod controller managing [SyncEngineState], auto-sync on app startup,
/// auto-sync when connectivity recovers (`none` -> `wifi`/`mobile`), and manual sync.
final class SyncControllerProvider
    extends $NotifierProvider<SyncController, SyncEngineState> {
  /// Riverpod controller managing [SyncEngineState], auto-sync on app startup,
  /// auto-sync when connectivity recovers (`none` -> `wifi`/`mobile`), and manual sync.
  SyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncControllerHash();

  @$internal
  @override
  SyncController create() => SyncController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncEngineState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncEngineState>(value),
    );
  }
}

String _$syncControllerHash() => r'649a84fa2e440dbb1bd1922edf51833e3804a116';

/// Riverpod controller managing [SyncEngineState], auto-sync on app startup,
/// auto-sync when connectivity recovers (`none` -> `wifi`/`mobile`), and manual sync.

abstract class _$SyncController extends $Notifier<SyncEngineState> {
  SyncEngineState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SyncEngineState, SyncEngineState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncEngineState, SyncEngineState>,
              SyncEngineState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
