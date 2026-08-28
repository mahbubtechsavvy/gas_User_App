import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  NotificationProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _apiClient.get(ApiEndpoints.notifications);
      if (res is List) {
        _notifications = res.map((n) => NotificationModel.fromJson(n as Map<String, dynamic>)).toList();
      } else if (res is Map<String, dynamic> && res['items'] is List) {
        _notifications = (res['items'] as List).map((n) => NotificationModel.fromJson(n as Map<String, dynamic>)).toList();
      }
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.unreadNotificationsCount);
      if (res is Map<String, dynamic> && res['count'] != null) {
        _unreadCount = res['count'] as int;
        notifyListeners();
      }
    } catch (_) {
      // Soft-fail
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.patch(ApiEndpoints.readNotification(notificationId));
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    } catch (_) {
      // Soft-fail
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.post(ApiEndpoints.readAllNotifications);
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {
      // Soft-fail
    }
  }
}
