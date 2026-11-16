// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_backup_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localBackupService)
final localBackupServiceProvider = LocalBackupServiceProvider._();

final class LocalBackupServiceProvider
    extends
        $FunctionalProvider<
          LocalBackupService,
          LocalBackupService,
          LocalBackupService
        >
    with $Provider<LocalBackupService> {
  LocalBackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localBackupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localBackupServiceHash();

  @$internal
  @override
  $ProviderElement<LocalBackupService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalBackupService create(Ref ref) {
    return localBackupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalBackupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalBackupService>(value),
    );
  }
}

String _$localBackupServiceHash() =>
    r'9bab72ac4b0b076a3a97a6aeeeb804b56cb78981';
