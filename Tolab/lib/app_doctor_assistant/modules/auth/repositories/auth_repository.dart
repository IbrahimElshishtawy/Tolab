import '../../../core/models/session_user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<({SessionUser user, Map<String, dynamic> tokens})> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/staff-portal/auth/login',
      data: {
        'university_email': email,
        'password': password,
        'device_name': 'flutter-app',
      },
      parser: _asMap,
    );

    final data = _asMap(response.data);
    final user = SessionUser.fromJson(_asMap(data['user']));
    final tokens = _asMap(data['tokens']);

    await _tokenStorage.write({
      ...tokens,
      'user': user.toJson(),
    });

    return (user: user, tokens: tokens);
  }

  Future<SessionUser?> restoreSession() async {
    final session = await _tokenStorage.read();
    final userJson = session?['user'];
    if (userJson is Map<String, dynamic>) {
      return SessionUser.fromJson(userJson);
    }

    return null;
  }

  Future<SessionUser> fetchCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff-portal/profile',
      parser: _asMap,
    );

    final user = SessionUser.fromJson(_asMap(response.data));
    final session = await _tokenStorage.read() ?? <String, dynamic>{};
    await _tokenStorage.write({
      ...session,
      'user': user.toJson(),
    });
    return user;
  }

  Future<void> logout() async {
    final session = await _tokenStorage.read() ?? <String, dynamic>{};
    await _apiClient.post<Object?>(
      '/staff-portal/auth/logout',
      data: {
        'refresh_token': session['refresh_token'],
      },
      parser: (_) => null,
    );
    await _tokenStorage.clear();
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post<Object?>(
      '/staff-portal/auth/forgot-password',
      data: {'university_email': email},
      parser: (_) => null,
    );
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
