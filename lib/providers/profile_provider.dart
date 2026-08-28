import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  bool _marketingOptIn = true;
  bool _orderUpdatesOptIn = true;
  bool _isLoading = false;
  String? _error;

  ProfileProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  bool get marketingOptIn => _marketingOptIn;
  bool get orderUpdatesOptIn => _orderUpdatesOptIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotificationPreferences() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.notificationPreferences);
      if (res is Map<String, dynamic>) {
        _marketingOptIn = res['marketingOptIn'] ?? true;
        _orderUpdatesOptIn = res['orderUpdatesOptIn'] ?? true;
        notifyListeners();
      }
    } catch (_) {
      // Soft-fail
    }
  }

  Future<void> updateNotificationPreferences({
    required bool marketing,
    required bool orderUpdates,
  }) async {
    _marketingOptIn = marketing;
    _orderUpdatesOptIn = orderUpdates;
    notifyListeners();

    try {
      await _apiClient.put(
        ApiEndpoints.notificationPreferences,
        body: {
          'marketingOptIn': marketing,
          'orderUpdatesOptIn': orderUpdates,
        },
      );
    } catch (_) {
      // Soft-fail
    }
  }

  Future<bool> submitSupportTicket({
    required String subject,
    required String message,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.post(
        '${ApiEndpoints.baseUrl}/me/support/tickets',
        body: {
          'subject': subject.trim(),
          'message': message.trim(),
          'category': category ?? 'GENERAL',
        },
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to submit support request: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
