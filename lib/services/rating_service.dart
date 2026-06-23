import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_service.dart';

class RatingService {
  static Future<void> submitRating({
    required String token,
    required int vendorId,
    required int orderId,
    required int rating,
    String? review,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/user/ratings.php'),
      headers: ApiService.authHeadersWithToken(token),
      body: json.encode({
        'vendor_id': vendorId,
        'order_id': orderId,
        'rating': rating,
        'review': review ?? '',
      }),
    );
    ApiService.handleResponse(response);
  }
}
