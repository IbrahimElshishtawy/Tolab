import 'dart:io';

import 'package:dio/dio.dart';

import '../errors/app_exceptions.dart';

class ApiExceptionMapper {
  const ApiExceptionMapper._();

  static AppException map(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return const TimeoutAppException();
      }

      if (error.error is SocketException ||
          error.type == DioExceptionType.connectionError) {
        return const OfflineException();
      }

      final response = error.response;
      final data = response?.data;
      final message = data is Map<String, dynamic>
          ? (data['message'] as String? ?? error.message ?? 'Request failed')
          : (error.message ?? 'Request failed');
      final errors = data is Map<String, dynamic> ? data['errors'] : null;

      switch (response?.statusCode) {
        case 401:
          return UnauthorizedException(message, errors, response?.statusCode);
        case 403:
          return ForbiddenException(message, errors, response?.statusCode);
        case 422:
          return ValidationException(message, errors, response?.statusCode);
        default:
          if ((response?.statusCode ?? 0) >= 500) {
            return ServerAppException(message, errors, response?.statusCode);
          }
          return UnexpectedAppException(message, errors, response?.statusCode);
      }
    }

    return UnexpectedAppException(error.toString());
  }
}
