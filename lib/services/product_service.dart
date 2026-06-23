import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  static Future<List<Product>> getAllProducts(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/user/products.php'),
      headers: ApiService.authHeadersWithToken(token),
    );
    final data = ApiService.handleResponse(response);
    final list = data['products'] is List
      ? data['products']
      : data['data'] is List
          ? data['data']
          : <dynamic>[];
    return list.map((product) => Product.fromJson(product)).toList();
  }

  static Future<List<Product>> getVendorProducts(
    String token,
    int vendorId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.apiBaseUrl}/user/products.php?vendor_id=$vendorId',
      ),
      headers: ApiService.authHeadersWithToken(token),
    );
    final data = ApiService.handleResponse(response);
    final list = data['products'] is List
      ? data['products']
      : data['data'] is List
          ? data['data']
          : <dynamic>[];
    return list.map((product) => Product.fromJson(product)).toList();
  }
}
