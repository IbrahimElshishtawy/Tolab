import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.errors = const <String, dynamic>{},
    this.statusCode,
  });

  final String message;
  final Map<String, dynamic> errors;
  final int? statusCode;

  factory ApiException.fromDio(Object error) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        return ApiException(
          message: responseData['message']?.toString() ?? 'Request failed.',
          errors: Map<String, dynamic>.from(
            responseData['errors'] as Map? ?? const <String, dynamic>{},
          ),
          statusCode: error.response?.statusCode,
        );
      }

      return ApiException(
        message: error.message ?? 'Network request failed.',
        statusCode: error.response?.statusCode,
      );
    }

    return ApiException(message: 'Unexpected error.');
  }

  @override
  String toString() => message;
}
