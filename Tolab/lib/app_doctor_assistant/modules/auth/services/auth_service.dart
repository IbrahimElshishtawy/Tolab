import '../../../core/models/session_user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

typedef StaffSessionPayload = ({SessionUser user, Map<String, dynamic> tokens});

class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<StaffSessionPayload> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<StaffSessionPayload>(
      '/staff-portal/auth/login',
      data: {
        'university_email': email,
        'password': password,
        'device_name': 'flutter-app',
      },
      parser: _parseSessionPayload,
    );

    final payload = response.data;
    if (payload == null) {
      throw ApiException(message: 'Login response is missing session data.');
    }

    return payload;
  }

  Future<SessionUser> fetchCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff-portal/profile',
      requiresAuth: true,
      parser: _asMap,
    );

    return SessionUser.fromJson(_asMap(response.data));
  }

  Future<void> logout({String? refreshToken}) async {
    await _apiClient.post<Object?>(
      '/staff-portal/auth/logout',
      requiresAuth: true,
      data: {
        if (refreshToken != null && refreshToken.isNotEmpty)
          'refresh_token': refreshToken,
      },
      parser: (_) => null,
    );
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post<Object?>(
      '/staff-portal/auth/forgot-password',
      data: {'university_email': email},
      parser: (_) => null,
    );
  }

  static StaffSessionPayload _parseSessionPayload(Object? value) {
    final data = _asMap(value);
    final nestedTokens = _asMap(data['tokens']);
    final accessToken =
        data['access_token']?.toString() ??
        data['token']?.toString() ??
        nestedTokens['access_token']?.toString() ??
        '';
    final refreshToken =
        data['refresh_token']?.toString() ??
        nestedTokens['refresh_token']?.toString() ??
        '';

    return (
      user: SessionUser.fromJson(_asMap(data['user'])),
      tokens: <String, dynamic>{
        'access_token': accessToken,
        'refresh_token': refreshToken,
      },
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
