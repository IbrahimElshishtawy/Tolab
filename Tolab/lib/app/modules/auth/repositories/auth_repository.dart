import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._demoDataService);

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
      if (error.statusCode != null) {
        rethrow;
      }
      if (email == 'admin@tolab.edu' && password == 'Admin@123') {
        return (
          const AuthTokens(
            accessToken:
                'demo-access-token-demo-access-token-demo-access-token',
            refreshToken:
                'demo-refresh-token-demo-refresh-token-demo-refresh-token',
          ),
          _demoDataService.adminProfile(),
        );
      }
      throw AppException('Invalid credentials.');
    } on DioException {
      if (email == 'admin@tolab.edu' && password == 'Admin@123') {
        return (
          const AuthTokens(
            accessToken:
                'demo-access-token-demo-access-token-demo-access-token',
            refreshToken:
                'demo-refresh-token-demo-refresh-token-demo-refresh-token',
          ),
          _demoDataService.adminProfile(),
        );
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
}
