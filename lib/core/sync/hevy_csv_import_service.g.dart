// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hevy_csv_import_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hevyCsvImportService)
final hevyCsvImportServiceProvider = HevyCsvImportServiceProvider._();

final class HevyCsvImportServiceProvider
    extends
        $FunctionalProvider<
          HevyCsvImportService,
          HevyCsvImportService,
          HevyCsvImportService
        >
    with $Provider<HevyCsvImportService> {
  HevyCsvImportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hevyCsvImportServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hevyCsvImportServiceHash();

  @$internal
  @override
  $ProviderElement<HevyCsvImportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HevyCsvImportService create(Ref ref) {
    return hevyCsvImportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HevyCsvImportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HevyCsvImportService>(value),
    );
  }
}

String _$hevyCsvImportServiceHash() =>
    r'51f0b4148c7b8c9082875abbf000b76f225395f5';
