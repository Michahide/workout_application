// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_compression_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mediaCompressionService)
final mediaCompressionServiceProvider = MediaCompressionServiceProvider._();

final class MediaCompressionServiceProvider
    extends
        $FunctionalProvider<
          MediaCompressionService,
          MediaCompressionService,
          MediaCompressionService
        >
    with $Provider<MediaCompressionService> {
  MediaCompressionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaCompressionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaCompressionServiceHash();

  @$internal
  @override
  $ProviderElement<MediaCompressionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MediaCompressionService create(Ref ref) {
    return mediaCompressionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaCompressionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaCompressionService>(value),
    );
  }
}

String _$mediaCompressionServiceHash() =>
    r'8fc7a411a29361cd1bfc07bb8c07266910b0e698';
