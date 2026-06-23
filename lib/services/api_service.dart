import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, token);
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.userIdKey, userId);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userIdKey);
  }

  static Map<String, String> get publicHeaders => const {
    'Content-Type': 'application/json',
  };

  static Future<Map<String, String>> get authHeaders async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> authHeadersWithToken(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static Map<String, dynamic> handleResponse(http.Response response) {
    final body = _decodeJsonResponse(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body['success'] == false) {
        throw Exception(body['message'] ?? body['error'] ?? 'Request failed');
      }
      return body;
    }

    final message =
        body['message'] ??
        body['error'] ??
        'Request failed with status ${response.statusCode}';
    throw Exception(message);
  }

  static Map<String, dynamic> _decodeJsonResponse(String body) {
    final trimmedBody = _extractJsonBody(body);

    try {
      final decoded = json.decode(trimmedBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (_) {
      throw Exception('Invalid JSON response from server');
    }
  }

  static String _extractJsonBody(String body) {
    final trimmed = body.trim();
    final jsonStartBrace = trimmed.indexOf('{');
    final jsonStartBracket = trimmed.indexOf('[');

    if (jsonStartBrace < 0 && jsonStartBracket < 0) {
      return trimmed;
    }

    final jsonStart = [
      if (jsonStartBrace >= 0) jsonStartBrace,
      if (jsonStartBracket >= 0) jsonStartBracket,
    ].reduce((a, b) => a < b ? a : b);

    return trimmed.substring(jsonStart);
  }
}
