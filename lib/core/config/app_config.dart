class AppConfig {
  static const String appName = 'Gas Lagba';
  static const String appVersion = '1.0.0';

  // API Base URL - points to live production API by default, customizable via compile-time define
  static const String _defaultBaseUrl = 'https://gaslagbaapi.gtgroup.cloud/api/v1';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  // Storage Keys
  static const String tokenKey = 'gas_lagba_auth_token';
  static const String userKey = 'gas_lagba_user_profile';
  static const String localeKey = 'gas_lagba_user_locale';
  static const String defaultAddressKey = 'gas_lagba_default_address';

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Business constants
  static const String defaultCurrencySymbol = '৳';
  static const String defaultCurrencyCode = 'BDT';
}
