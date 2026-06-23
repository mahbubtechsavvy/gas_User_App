import 'app_config.dart';

class ApiConfig {
  static const String baseUrl = AppConfig.apiBaseUrl;

  // API Endpoints
  static const String loginEndpoint = '$baseUrl/auth/login.php';
  static const String registerEndpoint = '$baseUrl/auth/register.php';
  static const String googleSignInEndpoint = '$baseUrl/auth/google_signin.php';
  static const String bannersEndpoint = '$baseUrl/user/banners.php';
  static const String productsEndpoint = '$baseUrl/user/products.php';
  static const String ordersEndpoint = '$baseUrl/user/orders.php';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
