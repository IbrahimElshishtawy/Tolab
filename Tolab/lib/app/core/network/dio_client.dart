import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../config/env_config.dart';
import '../services/session_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'token_refresh_coordinator.dart';

class DioClient {
  const DioClient._();

  static Dio build({
    required SessionService sessionService,
    required TokenRefreshCoordinator refreshCoordinator,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: Duration(
          seconds: int.parse(EnvConfig.connectTimeoutSeconds),
        ),
        receiveTimeout: Duration(
          seconds: int.parse(EnvConfig.receiveTimeoutSeconds),
        ),
        sendTimeout: Duration(
          seconds: int.parse(EnvConfig.receiveTimeoutSeconds),
        ),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      ConnectivityInterceptor(),
      AuthInterceptor(
        sessionService: sessionService,
        refreshCoordinator: refreshCoordinator,
      ),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          compact: true,
        ),
    ]);
    return dio;
  }
}
