import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/helpers/app_logger.dart';
import '../core/network/dio_client.dart';
import '../core/network/token_refresh_coordinator.dart';
import '../core/services/app_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/session_service.dart';
import '../core/services/theme_service.dart';
import '../core/storage/local_storage_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../data/datasources/base_remote_data_source.dart';
import '../modules/auth/datasources/auth_remote_data_source.dart';
import '../modules/auth/repositories/auth_repository.dart';

class AppConfig {
  const AppConfig._();

  static Future<void> bootstrap() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final localStorage = await Get.putAsync<LocalStorageService>(
      () async => LocalStorageService(sharedPreferences).init(),
      permanent: true,
    );
    final secureStorage = await Get.putAsync<SecureStorageService>(
      () async => SecureStorageService().init(),
      permanent: true,
    );
    await Get.putAsync<ThemeService>(
      () async => ThemeService(localStorage).init(),
      permanent: true,
    );
    await Get.putAsync<AppService>(
      () async => AppService(localStorage).init(),
      permanent: true,
    );
    await Get.putAsync<ConnectivityService>(
      () async => ConnectivityService().init(),
      permanent: true,
    );
    final sessionService = await Get.putAsync<SessionService>(
      () async => SessionService(
        secureStorage: secureStorage,
        localStorage: localStorage,
      ).init(),
      permanent: true,
    );

    final refreshCoordinator = Get.put<TokenRefreshCoordinator>(
      TokenRefreshCoordinator(sessionService: sessionService),
      permanent: true,
    );

    final dio = Get.put<Dio>(
      DioClient.build(
        sessionService: sessionService,
        refreshCoordinator: refreshCoordinator,
      ),
      permanent: true,
    );

    final remoteDataSource = Get.put<BaseRemoteDataSource>(
      BaseRemoteDataSource(dio: dio),
      permanent: true,
    );

    Get.put<AuthRemoteDataSource>(
      AuthRemoteDataSource(remoteDataSource),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepository(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        sessionService: sessionService,
      ),
      permanent: true,
    );

    FlutterError.onError = (details) {
      AppLogger.error(
        'Unhandled Flutter error',
        error: details.exception,
        stackTrace: details.stack,
      );
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      AppLogger.error(
        'Unhandled platform error',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    };
  }
}
