import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../errors/app_exceptions.dart';
import '../../services/connectivity_service.dart';

class ConnectivityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final connectivity = Get.find<ConnectivityService>();
    if (!connectivity.isOnline.value && options.extra['allowOffline'] != true) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: const OfflineException(),
          type: DioExceptionType.connectionError,
        ),
      );
    }

    handler.next(options);
  }
}
