import 'package:dio/dio.dart';

import '../../../config/admin_config.dart';
import '../models/auth_session_model.dart';
import '../models/login_request_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSessionModel> login(LoginRequestModel request) async {
    if (AdminConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return AuthSessionModel.fromJson(const {
        'access_token': 'mock_admin_access',
        'refresh_token': 'mock_admin_refresh',
        'user': {
          'name': 'Alaa Hassan',
          'email': 'admin@tolab.edu',
          'role': 'Super Admin',
          'phone': '+20 100 220 3344',
          'department': 'University Administration',
        },
      });
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );
    return AuthSessionModel.fromJson(
      response.data?['data'] as Map<String, dynamic>? ?? {},
    );
  }
}
