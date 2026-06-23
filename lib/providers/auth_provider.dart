import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _token;
  String? _userId;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  String? get userId => _userId;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConfig.tokenKey);
    _userId = prefs.getString(AppConfig.userIdKey);
    _isLoggedIn = _token != null && _token!.isNotEmpty;
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AuthService.login(
        identifier: identifier.trim(),
        password: password,
        isPhone: !_looksLikeEmail(identifier),
      );
      await _saveSession(data);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      _error = _errorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? fatherName,
    String? village,
    String? houseName,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AuthService.register(
        name: name.trim(),
        phone: phone.trim(),
        password: password,
        email: email,
        fatherName: fatherName,
        village: village,
        houseName: houseName,
        address: address,
      );
      await _saveSession(data);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      _error = _errorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    _token = null;
    _userId = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        data['token']?.toString() ?? data['access_token']?.toString() ?? '';
    final user = _mapValue(data['user']) ?? _mapValue(data['data']) ?? {};
    final userId =
        user['id']?.toString() ??
        user['user_id']?.toString() ??
        data['user_id']?.toString() ??
        data['id']?.toString() ??
        '';

    if (token.isEmpty) {
      throw Exception('No authentication token received');
    }

    await prefs.setString(AppConfig.tokenKey, token);
    await prefs.setString(AppConfig.userIdKey, userId);
    _token = token;
    _userId = userId;
  }

  static bool _looksLikeEmail(String value) => value.contains('@');

  static String _errorMessage(Object error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (error.toString().contains('TimeoutException')) {
      return 'Connection timed out. Please try again.';
    }
    final message = error.toString().replaceAll('Exception: ', '');
    return message.isEmpty ? 'Something went wrong' : message;
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
