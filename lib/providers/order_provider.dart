import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await OrderService.getOrders(token);
      _selectedOrder = null;
    } catch (e) {
      _error = _errorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrder(String token, int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrder = await OrderService.getOrder(token, orderId);
    } catch (e) {
      _error = _errorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static String _errorMessage(Object error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (error.toString().contains('TimeoutException')) {
      return 'Connection timed out. Please try again.';
    }
    final message = error.toString().replaceAll('Exception: ', '');
    return message.isEmpty ? 'Could not load orders' : message;
  }
}
