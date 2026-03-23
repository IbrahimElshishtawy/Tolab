import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../errors/app_exceptions.dart';
import '../../helpers/app_logger.dart';
import '../../services/session_service.dart';
import '../token_refresh_coordinator.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SessionService sessionService,
    required TokenRefreshCoordinator refreshCoordinator,
  }) : _sessionService = sessionService,
       _refreshCoordinator = refreshCoordinator;

  final SessionService _sessionService;
  final TokenRefreshCoordinator _refreshCoordinator;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final accessToken = _sessionService.accessToken;
    if (accessToken?.isNotEmpty == true) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final shouldRetry =
        err.response?.statusCode == 401 &&
        requestOptions.extra['skipRefresh'] != true &&
        requestOptions.extra['retried'] != true &&
        _sessionService.refreshToken?.isNotEmpty == true;

    if (!shouldRetry) {
      return handler.next(err);
    }

    try {
      final refreshedAccessToken = await _refreshCoordinator.refreshToken();
      if (refreshedAccessToken == null) {
        throw const UnauthorizedException();
      }

      final clonedOptions = requestOptions.copyWith(
        headers: Map<String, dynamic>.from(requestOptions.headers)
          ..['Authorization'] = 'Bearer $refreshedAccessToken',
        extra: Map<String, dynamic>.from(requestOptions.extra)
          ..['retried'] = true,
      );

      final response = await Get.find<Dio>().fetch<dynamic>(clonedOptions);
      return handler.resolve(response);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Request retry after refresh failed',
        error: error,
        stackTrace: stackTrace,
      );
      await _sessionService.clearSession(force: true);
      return handler.next(err);
    }
  }
}
