import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

class ApiExceptionMapper {
  const ApiExceptionMapper._();

  static AppException map(Object error) {
    if (error is AppException) return error;
    if (error is DioException) {
      final message = error.response?.data is Map<String, dynamic>
          ? (error.response?.data['message'] as String? ??
                'Request failed unexpectedly.')
          : switch (error.type) {
              DioExceptionType.connectionTimeout => 'Connection timeout.',
              DioExceptionType.receiveTimeout => 'Response timeout.',
              DioExceptionType.connectionError => 'No internet connection.',
              DioExceptionType.badCertificate => 'Invalid certificate.',
              DioExceptionType.cancel => 'Request cancelled.',
              _ => 'Something went wrong.',
            };
      return AppException(message);
    }
    return const AppException('Unexpected error occurred.');
  }
}
