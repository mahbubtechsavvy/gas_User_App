import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<OrderModel> _orders = [];
  OrderModel? _currentOrder;
  bool _isLoading = false;
  String? _error;

  OrderProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  List<OrderModel> get orders => _orders;
  List<OrderModel> get activeOrders => _orders.where((o) => o.status.isActive).toList();
  List<OrderModel> get historyOrders => _orders.where((o) => o.status.isTerminal).toList();
  OrderModel? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _apiClient.get(ApiEndpoints.orders);
      if (res is List) {
        _orders = res.map((o) => OrderModel.fromJson(o as Map<String, dynamic>)).toList();
      } else if (res is Map<String, dynamic> && res['items'] is List) {
        _orders = (res['items'] as List).map((o) => OrderModel.fromJson(o as Map<String, dynamic>)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load orders: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> fetchOrderDetails(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _apiClient.get(ApiEndpoints.order(orderId));
      if (res is Map<String, dynamic>) {
        _currentOrder = OrderModel.fromJson(res);
        _isLoading = false;
        notifyListeners();
        return _currentOrder;
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Failed to load order details: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _apiClient.post(
        ApiEndpoints.cancelOrder(orderId),
        body: {'reason': reason.trim()},
      );

      if (res is Map<String, dynamic>) {
        final updated = OrderModel.fromJson(res);
        final idx = _orders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          _orders[idx] = updated;
        }
        if (_currentOrder?.id == orderId) {
          _currentOrder = updated;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }

      await fetchOrders();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Cancellation failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
