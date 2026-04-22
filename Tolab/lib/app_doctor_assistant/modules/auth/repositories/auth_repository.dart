import '../../../core/models/session_user.dart';
import '../../../core/storage/token_storage.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository(this._authService, this._tokenStorage);

  static const String _devTestEmail = 'doctor@tolab.edu';
  static const String _devTestPassword = '123456';

  final AuthService _authService;
  final TokenStorage _tokenStorage;

  Future<({SessionUser user, Map<String, dynamic> tokens})> login({
    required String email,
    required String password,
  }) async {
    final payload = await _authService.login(email: email, password: password);
    await _persistSession(user: payload.user, tokens: payload.tokens);
    return payload;
  }

  Future<({SessionUser user, Map<String, dynamic> tokens})>
  createDevTestUser() async {
    return login(email: _devTestEmail, password: _devTestPassword);
  }

  Future<SessionUser?> restoreSession() async {
    final session = await _tokenStorage.read();
    final userJson = _asMap(session?['user']);
    if (userJson.isNotEmpty) {
      return SessionUser.fromJson(userJson);
    }

    return null;
  }

  Future<SessionUser> fetchCurrentUser() async {
    final session = await _tokenStorage.read() ?? <String, dynamic>{};
    final user = await _authService.fetchCurrentUser();
    await _tokenStorage.write({...session, 'user': user.toJson()});
    return user;
  }

  Future<void> logout() async {
    final session = await _tokenStorage.read() ?? <String, dynamic>{};
    try {
      await _authService.logout(
        refreshToken: session['refresh_token']?.toString(),
      );
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<void> forgotPassword(String email) async {
    await _authService.forgotPassword(email);
  }

  Future<void> _persistSession({
    required SessionUser user,
    required Map<String, dynamic> tokens,
  }) async {
    await _tokenStorage.write({
      ...tokens,
      'user': user.toJson(),
      'local_session': false,
    });
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const <String, dynamic>{};
  }
}
