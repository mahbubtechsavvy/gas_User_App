import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(AppConfig.tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _instance;
    return prefs.getString(AppConfig.tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await _instance;
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userKey);
  }

  Future<void> saveUserProfile(Map<String, dynamic> userJson) async {
    final prefs = await _instance;
    await prefs.setString(AppConfig.userKey, jsonEncode(userJson));
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await _instance;
    final jsonStr = prefs.getString(AppConfig.userKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocale(String locale) async {
    final prefs = await _instance;
    await prefs.setString(AppConfig.localeKey, locale);
  }

  Future<String?> getLocale() async {
    final prefs = await _instance;
    return prefs.getString(AppConfig.localeKey);
  }

  Future<void> saveDefaultAddressId(String addressId) async {
    final prefs = await _instance;
    await prefs.setString(AppConfig.defaultAddressKey, addressId);
  }

  Future<String?> getDefaultAddressId() async {
    final prefs = await _instance;
    return prefs.getString(AppConfig.defaultAddressKey);
  }

  Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
