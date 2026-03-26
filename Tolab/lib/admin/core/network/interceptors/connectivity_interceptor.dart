import 'package:dio/dio.dart';

import '../../errors/app_exception.dart';
import '../../services/connectivity_service.dart';

class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._connectivityService);

  final ConnectivityService _connectivityService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_connectivityService.isOnline.value) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const AppException('No internet connection.'),
          type: DioExceptionType.connectionError,
        ),
      );
      return;
    }
    super.onRequest(options, handler);
  }
}
