import 'package:dio/dio.dart';

import '../../services/session_service.dart';
import '../token_refresh_coordinator.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required SessionService sessionService})
    : _sessionService = sessionService,
      _refreshCoordinator = TokenRefreshCoordinator(sessionService);

  final SessionService _sessionService;
  final TokenRefreshCoordinator _refreshCoordinator;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _sessionService.accessToken.value;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    final isRefreshCall = err.requestOptions.path.contains('/auth/refresh');
    if (!isUnauthorized || alreadyRetried || isRefreshCall) {
      return super.onError(err, handler);
    }

    final refreshed = await _refreshCoordinator.refresh();
    if (!refreshed) {
      await _sessionService.clear();
      return super.onError(err, handler);
    }

    final options = err.requestOptions;
    options.headers['Authorization'] =
        'Bearer ${_sessionService.accessToken.value}';
    options.extra['retried'] = true;
    final response = await Dio().fetch(options);
    handler.resolve(response);
  }
}
