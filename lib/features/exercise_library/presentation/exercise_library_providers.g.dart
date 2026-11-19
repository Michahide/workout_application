// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_library_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExerciseFilterController)
final exerciseFilterControllerProvider = ExerciseFilterControllerProvider._();

final class ExerciseFilterControllerProvider
    extends $NotifierProvider<ExerciseFilterController, ExerciseFilterState> {
  ExerciseFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseFilterControllerHash();

  @$internal
  @override
  ExerciseFilterController create() => ExerciseFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExerciseFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExerciseFilterState>(value),
    );
  }
}

String _$exerciseFilterControllerHash() =>
    r'93fb8be76d19db127e6789fa43e6d5af1044c291';

abstract class _$ExerciseFilterController
    extends $Notifier<ExerciseFilterState> {
  ExerciseFilterState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ExerciseFilterState, ExerciseFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExerciseFilterState, ExerciseFilterState>,
              ExerciseFilterState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExerciseMediaController)
final exerciseMediaControllerProvider = ExerciseMediaControllerFamily._();

final class ExerciseMediaControllerProvider
    extends
        $NotifierProvider<ExerciseMediaController, ExerciseMediaUploadState> {
  ExerciseMediaControllerProvider._({
    required ExerciseMediaControllerFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'exerciseMediaControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseMediaControllerHash();

  @override
  String toString() {
    return r'exerciseMediaControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ExerciseMediaController create() => ExerciseMediaController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExerciseMediaUploadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExerciseMediaUploadState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseMediaControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseMediaControllerHash() =>
    r'929f17ed397d12c2bf62c126afbede842a5a34b3';

final class ExerciseMediaControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ExerciseMediaController,
          ExerciseMediaUploadState,
          ExerciseMediaUploadState,
          ExerciseMediaUploadState,
          (String, String?)
        > {
  ExerciseMediaControllerFamily._()
    : super(
        retry: null,
        name: r'exerciseMediaControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExerciseMediaControllerProvider call(
    String exerciseId, [
    String? gymMachineId,
  ]) => ExerciseMediaControllerProvider._(
    argument: (exerciseId, gymMachineId),
    from: this,
  );

  @override
  String toString() => r'exerciseMediaControllerProvider';
}

abstract class _$ExerciseMediaController
    extends $Notifier<ExerciseMediaUploadState> {
  late final _$args = ref.$arg as (String, String?);
  String get exerciseId => _$args.$1;
  String? get gymMachineId => _$args.$2;

  ExerciseMediaUploadState build(String exerciseId, [String? gymMachineId]);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ExerciseMediaUploadState, ExerciseMediaUploadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExerciseMediaUploadState, ExerciseMediaUploadState>,
              ExerciseMediaUploadState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
