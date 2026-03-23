import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../config/env_config.dart';
import '../errors/app_exceptions.dart';
import '../helpers/app_logger.dart';
import '../services/session_service.dart';

class TokenRefreshCoordinator extends GetxService {
  TokenRefreshCoordinator({required SessionService sessionService})
    : _sessionService = sessionService;

  final SessionService _sessionService;
  Future<String?>? _refreshingTask;

  Future<String?> refreshToken() {
    _refreshingTask ??= _performRefresh().whenComplete(() {
      _refreshingTask = null;
    });
    return _refreshingTask!;
  }

  Future<String?> _performRefresh() async {
    final refreshToken = _sessionService.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await _sessionService.clearSession(force: true);
      throw const UnauthorizedException('Refresh token is missing');
    }

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: EnvConfig.baseUrl,
          connectTimeout: Duration(
            seconds: int.parse(EnvConfig.connectTimeoutSeconds),
          ),
          receiveTimeout: Duration(
            seconds: int.parse(EnvConfig.receiveTimeoutSeconds),
          ),
        ),
      );
      final response = await dio.post<Map<String, dynamic>>(
        EnvConfig.refreshPath,
        data: {'refresh_token': refreshToken},
      );
      final payload = response.data ?? <String, dynamic>{};
      final data =
          payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final accessToken =
          (data['accessToken'] ?? data['access_token'] ?? data['token'])
              as String?;
      final nextRefreshToken =
          (data['refreshToken'] ?? data['refresh_token']) as String? ??
          refreshToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw const UnauthorizedException('Refresh response was invalid');
      }

      await _sessionService.updateTokens(
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
      );
      return accessToken;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Token refresh failed',
        error: error,
        stackTrace: stackTrace,
      );
      await _sessionService.clearSession(force: true);
      rethrow;
    }
  }
}
