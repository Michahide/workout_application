// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_timer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RestTimerController)
final restTimerControllerProvider = RestTimerControllerProvider._();

final class RestTimerControllerProvider
    extends $NotifierProvider<RestTimerController, RestTimerState> {
  RestTimerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restTimerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restTimerControllerHash();

  @$internal
  @override
  RestTimerController create() => RestTimerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestTimerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestTimerState>(value),
    );
  }
}

String _$restTimerControllerHash() =>
    r'6a04308476175acdf34d51a2570dcc9e4938cc14';

abstract class _$RestTimerController extends $Notifier<RestTimerState> {
  RestTimerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RestTimerState, RestTimerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RestTimerState, RestTimerState>,
              RestTimerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
