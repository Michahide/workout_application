import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sync_preferences_service.g.dart';

/// Configuration snapshot for Cloud Sync.
class SyncEndpointConfig {
  const SyncEndpointConfig({
    required this.apiBaseUrl,
    required this.authToken,
    this.lastSyncTimestamp,
  });

  final String apiBaseUrl;
  final String authToken;
  final DateTime? lastSyncTimestamp;

  bool get isConfigured => apiBaseUrl.trim().isNotEmpty;
}

/// Manages persistent storage of `last_sync_timestamp`, `api_base_url`,
/// and `auth_token` using `SharedPreferences`.
class SyncPreferencesService {
  static const String _kKeyLastSyncTimestamp = 'sync_last_sync_timestamp_utc';
  static const String _kKeyApiBaseUrl = 'sync_api_base_url';
  static const String _kKeyAuthToken = 'sync_auth_token';

  Future<SyncEndpointConfig> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString(_kKeyApiBaseUrl) ?? '';
    final token = prefs.getString(_kKeyAuthToken) ?? '';
    final rawLastSync = prefs.getString(_kKeyLastSyncTimestamp);
    final parsedLastSync =
        rawLastSync != null ? DateTime.tryParse(rawLastSync)?.toUtc() : null;

    return SyncEndpointConfig(
      apiBaseUrl: baseUrl,
      authToken: token,
      lastSyncTimestamp: parsedLastSync,
    );
  }

  Future<void> saveEndpointConfig({
    required String apiBaseUrl,
    required String authToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sanitizedUrl = apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    await prefs.setString(_kKeyApiBaseUrl, sanitizedUrl);
    await prefs.setString(_kKeyAuthToken, authToken.trim());
  }

  Future<DateTime?> getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKeyLastSyncTimestamp);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  Future<void> setLastSyncTimestamp(DateTime timestampUtc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kKeyLastSyncTimestamp,
      timestampUtc.toUtc().toIso8601String(),
    );
  }
}

@Riverpod(keepAlive: true)
SyncPreferencesService syncPreferencesService(Ref ref) {
  return SyncPreferencesService();
}
