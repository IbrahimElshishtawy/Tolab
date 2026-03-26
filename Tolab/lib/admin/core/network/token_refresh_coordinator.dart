import 'package:dio/dio.dart';

import '../../config/admin_config.dart';
import '../services/session_service.dart';

class TokenRefreshCoordinator {
  TokenRefreshCoordinator(this._sessionService);

  final SessionService _sessionService;
  Future<bool>? _refreshTask;

  Future<bool> refresh() => _refreshTask ??= _refreshToken();

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _sessionService.refreshToken.value;
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final dio = Dio(
        BaseOptions(
          baseUrl: AdminConfig.baseUrl,
          connectTimeout: AdminConfig.connectTimeout,
          receiveTimeout: AdminConfig.receiveTimeout,
        ),
      );
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final access = data['access_token'] as String?;
      final refresh = data['refresh_token'] as String? ?? refreshToken;
      if (access == null) return false;
      await _sessionService.updateTokens(access: access, refresh: refresh);
      return true;
    } catch (_) {
      return false;
    } finally {
      _refreshTask = null;
    }
  }
}
