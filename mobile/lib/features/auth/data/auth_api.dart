import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AuthApi {
  final ApiClient _client = ApiClient();

  Future<Response> login(String email, String password) async {
    return await _client.postForm(
      ApiEndpoints.login,
      {
        'username': email,
        'password': password,
      },
    );
  }

  Future<Response> refresh(String refreshToken) async {
    return await _client.post(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );
  }

  Future<Response> logout() async {
    return await _client.post("/auth/logout");
  }

  Future<Response> getMe() async {
    return await _client.get(ApiEndpoints.me);
  }
}
