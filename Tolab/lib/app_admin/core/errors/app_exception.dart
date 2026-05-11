class AppException implements Exception {
  AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class SessionExpiredException extends AppException {
  SessionExpiredException() : super('Session expired, please login again.', statusCode: 401);
}

class TokenRefreshException extends AppException {
  TokenRefreshException() : super('Failed to refresh token. Please login again.', statusCode: 401);
}
