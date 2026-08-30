import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../storage/storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  final http.Client _httpClient;
  final StorageService _storageService;

  ApiClient({
    http.Client? httpClient,
    StorageService? storageService,
  })  : _httpClient = httpClient ?? http.Client(),
        _storageService = storageService ?? StorageService();

  Future<Map<String, String>> _buildHeaders({
    String? idempotencyKey,
    bool requiresAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final locale = await _storageService.getLocale();
    if (locale != null && locale.isNotEmpty) {
      headers['Accept-Language'] = locale;
    } else {
      headers['Accept-Language'] = 'bn';
    }

    if (requiresAuth) {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['X-Idempotency-Key'] = idempotencyKey;
    }

    return headers;
  }

  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        final stringParams = queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...stringParams,
        });
      }

      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final response = await _httpClient
          .get(uri, headers: headers)
          .timeout(AppConfig.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection or server unreachable');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<dynamic> post(
    String url, {
    dynamic body,
    String? idempotencyKey,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _buildHeaders(
        idempotencyKey: idempotencyKey,
        requiresAuth: requiresAuth,
      );

      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _httpClient
          .post(uri, headers: headers, body: encodedBody)
          .timeout(AppConfig.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection or server unreachable');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiException('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  Future<dynamic> patch(
    String url, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);

      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _httpClient
          .patch(uri, headers: headers, body: encodedBody)
          .timeout(AppConfig.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection or server unreachable');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<dynamic> put(
    String url, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);

      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _httpClient
          .put(uri, headers: headers, body: encodedBody)
          .timeout(AppConfig.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection or server unreachable');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<dynamic> delete(
    String url, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);

      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _httpClient
          .delete(uri, headers: headers, body: encodedBody)
          .timeout(AppConfig.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('No internet connection or server unreachable');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic decodedBody;

    if (response.body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        decodedBody = response.body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decodedBody;
    }

    String errorMessage = 'An unexpected error occurred';
    String? errorCode;

    if (decodedBody is Map<String, dynamic>) {
      if (decodedBody['message'] is List) {
        errorMessage = (decodedBody['message'] as List).join(', ');
      } else if (decodedBody['message'] is String) {
        errorMessage = decodedBody['message'];
      } else if (decodedBody['error'] is String) {
        errorMessage = decodedBody['error'];
      }
      errorCode = decodedBody['code']?.toString();
    } else if (decodedBody is String && decodedBody.isNotEmpty) {
      errorMessage = decodedBody;
    }

    if (statusCode == 401) {
      _storageService.clearToken();
    }

    throw ApiException(
      errorMessage,
      statusCode: statusCode,
      code: errorCode,
      data: decodedBody,
    );
  }
}
