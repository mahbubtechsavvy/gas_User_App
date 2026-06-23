import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/user/get_profile.php'),
      headers: ApiService.authHeadersWithToken(token),
    );
    final data = ApiService.handleResponse(response);
    return data['user'] ?? data['data'] ?? {};
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String mobile,
    String? email,
    String? fatherName,
    String? village,
    String? houseName,
    File? profileImage,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBaseUrl}/user/update_profile.php'),
    );
    request.headers.addAll(ApiService.authHeadersWithToken(token));
    request.fields['name'] = name;
    request.fields['mobile'] = mobile;
    request.fields['email'] = email ?? '';
    request.fields['father_name'] = fatherName ?? '';
    request.fields['village'] = village ?? '';
    request.fields['house_name'] = houseName ?? '';

    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_image', profileImage.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = ApiService.handleResponse(response);
    return data['user'] ?? data['data'] ?? {};
  }

  static Future<void> updateFcmToken(String token, String fcmToken) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBaseUrl}/user/update_profile.php'),
    );
    request.headers.addAll(ApiService.authHeadersWithToken(token));
    request.fields['fcm_token'] = fcmToken;

    final streamedResponse = await request.send();
    await http.Response.fromStream(streamedResponse);
  }
}
