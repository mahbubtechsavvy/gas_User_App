import 'dart:io';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../config/app_config.dart';

class PushTokenService {
  final ApiClient _apiClient;
  String? _currentToken;

  PushTokenService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<void> registerDeviceToken(String token) async {
    _currentToken = token;
    try {
      final platform = Platform.isAndroid ? 'ANDROID' : (Platform.isIOS ? 'IOS' : 'WEB');
      await _apiClient.post(
        ApiEndpoints.devices,
        body: {
          'token': token,
          'platform': platform,
          'appVersion': AppConfig.appVersion,
        },
      );
    } catch (_) {
      // Soft-fail: device registration will retry on next session start
    }
  }

  Future<void> deregisterDeviceToken() async {
    if (_currentToken == null) return;
    try {
      await _apiClient.delete(ApiEndpoints.device(_currentToken!));
      _currentToken = null;
    } catch (_) {
      // Soft-fail
    }
  }
}
