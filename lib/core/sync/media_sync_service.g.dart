// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mediaSyncService)
final mediaSyncServiceProvider = MediaSyncServiceProvider._();

final class MediaSyncServiceProvider
    extends
        $FunctionalProvider<
          MediaSyncService,
          MediaSyncService,
          MediaSyncService
        >
    with $Provider<MediaSyncService> {
  MediaSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaSyncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaSyncServiceHash();

  @$internal
  @override
  $ProviderElement<MediaSyncService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaSyncService create(Ref ref) {
    return mediaSyncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaSyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaSyncService>(value),
    );
  }
}

String _$mediaSyncServiceHash() => r'b41ff71854d8c826fa21812d221b7d909a32766c';
