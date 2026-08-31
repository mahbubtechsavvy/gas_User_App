import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../core/storage/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final StorageService _storageService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _otpSent = false;
  String? _pendingEmail;

  AuthProvider({
    ApiClient? apiClient,
    StorageService? storageService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storageService = storageService ?? StorageService();

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get otpSent => _otpSent;
  String? get pendingEmail => _pendingEmail;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final res = await _apiClient.get(ApiEndpoints.meCustomer);
      if (res is Map<String, dynamic>) {
        _currentUser = UserModel.fromJson(res);
        await _storageService.saveUserProfile(_currentUser!.toJson());
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      // If network fails on restore, attempt loading cached user
      final cached = await _storageService.getUserProfile();
      if (cached != null) {
        _currentUser = UserModel.fromJson(cached);
      }
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    }
  }



  Future<bool> requestOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.post(
        ApiEndpoints.requestOtp,
        body: {'email': email.trim().toLowerCase()},
        requiresAuth: false,
      );
      _pendingEmail = email.trim().toLowerCase();
      _otpSent = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to request login code: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        body: {
          'email': email.trim().toLowerCase(),
          'code': token.trim(),
        },
        requiresAuth: false,
      );

      if (res is Map<String, dynamic>) {
        final accessToken = res['accessToken']?.toString() ?? res['token']?.toString();
        if (accessToken != null && accessToken.isNotEmpty) {
          await _storageService.saveToken(accessToken);
        }

        // Fetch customer profile
        try {
          final customerRes = await _apiClient.get(ApiEndpoints.meCustomer);
          if (customerRes is Map<String, dynamic>) {
            _currentUser = UserModel.fromJson(customerRes);
          } else {
            _currentUser = UserModel.fromJson(res['user'] ?? res);
          }
        } catch (_) {
          _currentUser = UserModel.fromJson(res['user'] ?? res);
        }

        await _storageService.saveUserProfile(_currentUser!.toJson());
        _otpSent = false;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Invalid verification response';
      _isLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Verification failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomerProfile({
    required String fullName,
    required String phone,
    String? avatarKey,
    String? defaultAddressId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String formattedPhone = phone.trim();
    if (formattedPhone.startsWith('01')) {
      formattedPhone = '+88$formattedPhone';
    } else if (formattedPhone.startsWith('8801')) {
      formattedPhone = '+$formattedPhone';
    } else if (!formattedPhone.startsWith('+8801') && formattedPhone.isNotEmpty) {
      formattedPhone = '+880$formattedPhone';
    }

    try {
      final res = await _apiClient.patch(
        ApiEndpoints.me,
        body: {
          'fullName': fullName.trim(),
          if (formattedPhone.isNotEmpty) 'phone': formattedPhone,
          if (avatarKey != null && avatarKey.isNotEmpty) 'avatarKey': avatarKey,
        },
      );

      if (res is Map<String, dynamic>) {
        _currentUser = UserModel.fromJson(res);
        await _storageService.saveUserProfile(_currentUser!.toJson());
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearToken();
    _currentUser = null;
    _otpSent = false;
    _pendingEmail = null;
    _error = null;
    notifyListeners();
  }
}
