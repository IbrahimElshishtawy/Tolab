// ignore_for_file: use_super_parameters

abstract class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final dynamic details;

  @override
  String toString() => message;
}

class OfflineException extends AppException {
  const OfflineException([super.message = 'No internet connection']);
}

class TimeoutAppException extends AppException {
  const TimeoutAppException([super.message = 'The request timed out']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    String message = 'Unauthorized',
    dynamic details,
    int? statusCode,
  ]) : super(message, details: details, statusCode: statusCode);
}

class ForbiddenException extends AppException {
  const ForbiddenException([
    String message = 'Forbidden',
    dynamic details,
    int? statusCode,
  ]) : super(message, details: details, statusCode: statusCode);
}

class ValidationException extends AppException {
  const ValidationException([
    String message = 'Validation failed',
    dynamic details,
    int? statusCode,
  ]) : super(message, details: details, statusCode: statusCode);
}

class ServerAppException extends AppException {
  const ServerAppException([
    String message = 'Server error',
    dynamic details,
    int? statusCode,
  ]) : super(message, details: details, statusCode: statusCode);
}

class UnexpectedAppException extends AppException {
  const UnexpectedAppException([
    String message = 'Something went wrong',
    dynamic details,
    int? statusCode,
  ]) : super(message, details: details, statusCode: statusCode);
}
