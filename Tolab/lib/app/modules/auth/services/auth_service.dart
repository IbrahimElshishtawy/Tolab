import '../../../core/storage/secure_storage_service.dart';
import '../../../shared/models/auth_models.dart';

class AuthService {
  AuthService(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<void> persistTokens(AuthTokens tokens) async {
    await _secureStorage.writeAccessToken(tokens.accessToken);
    await _secureStorage.writeRefreshToken(tokens.refreshToken);
  }

  Future<void> clearSession() => _secureStorage.clearSession();

  Future<bool> hasSession() async {
    final token = await _secureStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
