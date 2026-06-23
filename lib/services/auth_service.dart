import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_service.dart';

class AuthService {
  static const String _base = '${AppConfig.apiBaseUrl}/auth';

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    bool isPhone = true,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/login.php'),
      headers: ApiService.publicHeaders,
      body: json.encode({
        if (isPhone) 'phone': identifier else 'email': identifier,
        'password': password,
        'type': 'user',
      }),
    );
    final data = ApiService.handleResponse(response);
    return _normalizeSession(data);
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? fatherName,
    String? village,
    String? houseName,
    String? address,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/register.php'),
      headers: ApiService.publicHeaders,
      body: json.encode({
        'name': name,
        'phone': phone,
        'password': password,
        'user_type': 'user',
        if (email != null && email.isNotEmpty) 'email': email,
        if (fatherName != null) 'father_name': fatherName,
        if (village != null) 'village': village,
        if (houseName != null) 'house_name': houseName,
        if (address != null) 'address': address,
      }),
    );
    final data = ApiService.handleResponse(response);
    return _normalizeSession(data);
  }

  static Future<Map<String, dynamic>> googleSignIn({
    required String googleId,
    required String idToken,
    required String email,
    required String name,
    String? phone,
    String? profilePhoto,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/google_signin.php'),
      headers: ApiService.publicHeaders,
      body: json.encode({
        'google_id': googleId,
        'id_token': idToken,
        'email': email,
        'name': name,
        'profile_photo': profilePhoto ?? '',
        'user_type': 'user',
        'phone': phone ?? '',
      }),
    );
    final data = ApiService.handleResponse(response);
    return _normalizeSession(data);
  }

  static Map<String, dynamic> _normalizeSession(Map<String, dynamic> data) {
    final user = _mapValue(data['user']) ?? _mapValue(data['data']) ?? {};
    final token =
        data['token'] ??
        data['access_token'] ??
        user['token'] ??
        user['access_token'];

    if (token == null || token.toString().isEmpty) {
      throw Exception('No authentication token received');
    }

    return {
      'token': token,
      'user': user,
      'message': data['message'] ?? user['message'] ?? 'Login successful',
    };
  }

  static Map<String, dynamic>? _mapValue(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }
}
