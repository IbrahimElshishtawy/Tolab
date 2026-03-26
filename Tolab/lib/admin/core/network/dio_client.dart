import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../config/admin_config.dart';
import '../services/connectivity_service.dart';
import '../services/session_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';

class DioClient {
  const DioClient._();

  static Dio build({
    required ConnectivityService connectivityService,
    required SessionService sessionService,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AdminConfig.baseUrl,
        connectTimeout: AdminConfig.connectTimeout,
        receiveTimeout: AdminConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.addAll([
      ConnectivityInterceptor(connectivityService),
      AuthInterceptor(sessionService: sessionService),
      PrettyDioLogger(requestBody: true, responseBody: false),
    ]);
    return dio;
  }
}
