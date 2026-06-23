import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_service.dart';

class ForgotPasswordService {
  static const String _base = '${AppConfig.apiBaseUrl}/auth';

  static Future<Map<String, dynamic>> requestReset(String identifier) async {
    final response = await http.post(
      Uri.parse('${_base}/forgot_password.php'),
      headers: ApiService.publicHeaders,
      body: json.encode({
        'identifier': identifier.trim(),
      }),
    );
    return ApiService.handleResponse(response);
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('${_base}/verify_otp.php'),
      headers: ApiService.publicHeaders,
      body: json.encode({
        'identifier': identifier.trim(),
        'otp': otp.trim(),
      }),
    );
    return ApiService.handleResponse(response);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${_base}/reset_password.php'),
      headers: ApiService.publicHeaders,
      body: json.encode({
        'identifier': identifier.trim(),
        'otp': otp.trim(),
        'password': newPassword,
      }),
    );
    return ApiService.handleResponse(response);
  }
}
