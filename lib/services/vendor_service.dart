import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/vendor.dart';
import 'api_service.dart';

class VendorService {
  static Future<List<Vendor>> getVendors(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/user/vendors.php'),
      headers: ApiService.authHeadersWithToken(token),
    );
    final data = ApiService.handleResponse(response);
    final list = data['data'] is List ? data['data'] : <dynamic>[];
    return list.map((vendor) => Vendor.fromJson(vendor)).toList();
  }

  static Future<List<dynamic>> getBanners(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/user/banners.php'),
      headers: ApiService.authHeadersWithToken(token),
    );
    final data = ApiService.handleResponse(response);
    return data['data'] is List ? data['data'] : <dynamic>[];
  }
}
