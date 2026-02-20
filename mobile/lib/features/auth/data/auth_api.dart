import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AuthApi {
  final ApiClient _client = ApiClient();

  Future<Response> login(String email, String password) async {
    return await _client.post(
      ApiEndpoints.login,
      data: FormData.fromMap({
        'username': email,
        'password': password,
      }),
    );
  }

  Future<Response> getMe() async {
    return await _client.get(ApiEndpoints.me);
  }
}
