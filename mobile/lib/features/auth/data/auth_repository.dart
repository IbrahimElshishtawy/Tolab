import 'auth_api.dart';
import 'models.dart';
import '../../../core/storage/secure_store.dart';

class AuthRepository {
  final AuthApi _api = AuthApi();
  final SecureStore _store = SecureStore();

  Future<LoginResponse> login(String email, String password) async {
    final response = await _api.login(email, password);
    final loginResponse = LoginResponse.fromJson(response.data);

    await _store.saveToken(loginResponse.accessToken);
    await _store.saveRole(loginResponse.role);

    return loginResponse;
  }

  Future<void> logout() async {
    await _store.clear();
  }
}
