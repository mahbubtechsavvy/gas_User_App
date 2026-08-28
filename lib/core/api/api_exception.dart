class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final dynamic data;

  ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.data,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isRateLimited => statusCode == 429;
  bool get isValidationError => statusCode == 400 || statusCode == 422;

  @override
  String toString() => 'ApiException: $message (code: $code, status: $statusCode)';
}
