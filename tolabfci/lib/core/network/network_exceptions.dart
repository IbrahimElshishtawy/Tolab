import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import '../errors/user_messages.dart';

class NetworkExceptions {
  static AppException fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const AppException(UserMessages.timeoutError, code: 'timeout');
      case DioExceptionType.connectionError:
        return const AppException(UserMessages.networkError, code: 'network');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return const AppException(
            UserMessages.unauthorized,
            code: 'unauthorized',
          );
        }
        return AppException(
          error.response?.data is Map<String, dynamic>
              ? error.response?.data['message']?.toString() ??
                    UserMessages.genericError
              : UserMessages.genericError,
          code: 'server_error',
        );
      default:
        return const AppException(UserMessages.genericError, code: 'unknown');
    }
  }
}
