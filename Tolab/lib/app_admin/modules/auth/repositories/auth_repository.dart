import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._demoDataService);

  static const String _seededAdminEmail = 'admin@tolab.edu';
  static const String _seededAdminPassword = 'Admin@123';

  final ApiClient _apiClient;
  final DemoDataService _demoDataService;

  Future<(AuthTokens, UserProfile)> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post<(AuthTokens, UserProfile)>(
        '/auth/login',
        data: {'email': email, 'password': password},
        decoder: (json) {
          final map = json as JsonMap;
          return (
            AuthTokens.fromJson(map),
            UserProfile.fromJson(map['user'] as JsonMap),
          );
        },
      );
      return response;
    } on AppException catch (error) {
      if (error.statusCode != null &&
          !_shouldUseDemoFallback(error.statusCode, email, password)) {
        rethrow;
      }
      final demoSession = _buildDemoSession(email: email, password: password);
      if (demoSession != null) {
        return demoSession;
      }
      throw AppException('Invalid credentials.');
    } on DioException {
      final demoSession = _buildDemoSession(email: email, password: password);
      if (demoSession != null) {
        return demoSession;
      }
      throw AppException('Invalid credentials.');
    }
  }

  Future<UserProfile> me() async {
    try {
      return await _apiClient.get<UserProfile>(
        '/me',
        decoder: (json) => UserProfile.fromJson(json as JsonMap),
      );
    } catch (_) {
      return _demoDataService.adminProfile();
    }
  }

  bool _shouldUseDemoFallback(int? statusCode, String email, String password) {
    if (!_matchesSeededAdmin(email: email, password: password)) {
      return false;
    }

    return statusCode == null || statusCode == 401;
  }

  bool _matchesSeededAdmin({required String email, required String password}) {
    return email == _seededAdminEmail && password == _seededAdminPassword;
  }

  (AuthTokens, UserProfile)? _buildDemoSession({
    required String email,
    required String password,
  }) {
    if (!_matchesSeededAdmin(email: email, password: password)) {
      return null;
    }

    return (
      const AuthTokens(
        accessToken: 'demo-access-token-demo-access-token-demo-access-token',
        refreshToken:
            'demo-refresh-token-demo-refresh-token-demo-refresh-token',
      ),
      _demoDataService.adminProfile(),
    );
  }
}
