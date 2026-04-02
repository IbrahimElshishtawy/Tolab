import '../../../core/storage/secure_storage_service.dart';
import '../../../shared/models/auth_models.dart';

class AuthService {
  AuthService(this._secureStorage);

  final SecureStorageService _secureStorage;
  static const String _demoAccessTokenPrefix = 'demo-access-token';

  Future<void> persistTokens(AuthTokens tokens) async {
    await _secureStorage.writeAccessToken(tokens.accessToken);
    await _secureStorage.writeRefreshToken(tokens.refreshToken);
  }

  Future<void> clearSession() => _secureStorage.clearSession();

  Future<bool> hasSession() async {
    final token = await _secureStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasUsableSession() async {
    final token = await _secureStorage.readAccessToken();
    return token != null &&
        token.isNotEmpty &&
        !token.startsWith(_demoAccessTokenPrefix);
  }

  Future<bool> isDemoSession() async {
    final token = await _secureStorage.readAccessToken();
    return token != null &&
        token.isNotEmpty &&
        token.startsWith(_demoAccessTokenPrefix);
  }
}
