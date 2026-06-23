import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import 'api_service.dart';

class OrderService {
  static Future<Map<String, dynamic>> placeOrder({
    required String token,
    required int vendorId,
    required List<CartItem> items,
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    final orderItems = items.map((item) {
      return {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price': item.product.effectivePrice,
        'total': item.total,
      };
    }).toList();

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/user/orders.php'),
      headers: ApiService.authHeadersWithToken(token),
      body: json.encode({
        'vendor_id': vendorId,
        'items': orderItems,
        'total_amount': items.fold(0.0, (sum, item) => sum + item.total),
        'delivery_charge': 0,
        'delivery_address': deliveryAddress,
        'payment_method': paymentMethod.toLowerCase(),
        'notes': notes ?? '',
      }),
    );
    return ApiService.handleResponse(response);
  }

  static Future<List<Order>> getOrders(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/user/orders.php'),
      headers: ApiService.authHeadersWithToken(token),
    );
    final data = ApiService.handleResponse(response);
    final list = data['orders'] is List
        ? data['orders']
        : data['data'] is List
        ? data['data']
        : <dynamic>[];
    return list.map((order) => Order.fromJson(order)).toList();
  }

  static Future<Order> getOrder(String token, int orderId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/user/orders.php?id=$orderId'),
      headers: ApiService.authHeadersWithToken(token),
    );
    final data = ApiService.handleResponse(response);
    return Order.fromJson(data['data'] ?? data['order'] ?? {});
  }
}
