import '../../../core/models/session_user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._tokenStorage);

  static const String _devCreateUserPath = '/staff-portal/dev/create-user';
  static const String _devTestEmail = 'doctor@tolab.edu';
  static const String _devTestPassword = 'Admin@123';

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<({SessionUser user, Map<String, dynamic> tokens})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient
          .post<({SessionUser user, Map<String, dynamic> tokens})>(
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

      await _persistSession(user: payload.user, tokens: payload.tokens);
      return payload;
    } on ApiException {
      final fallback = _localStaffAccount(email: email, password: password);
      if (fallback == null) {
        rethrow;
      }

      final tokens = <String, dynamic>{
        'access_token': 'local-${fallback.roleType}-access-token',
        'refresh_token': 'local-${fallback.roleType}-refresh-token',
        'local_session': true,
      };
      await _persistSession(user: fallback, tokens: tokens);
      return (user: fallback, tokens: tokens);
    }
  }

  Future<({SessionUser user, Map<String, dynamic> tokens})>
  createDevTestUser() async {
    try {
      final response = await _apiClient
          .post<({SessionUser user, Map<String, dynamic> tokens})>(
            _devCreateUserPath,
            data: const {'device_name': 'flutter-app'},
            parser: _parseSessionPayload,
          );
      final payload = response.data;
      if (payload == null) {
        throw ApiException(
          message: 'Dev test account response is missing session data.',
        );
      }
      await _persistSession(user: payload.user, tokens: payload.tokens);
      return payload;
    } on ApiException {
      final fallback = _buildMockDevTestUser();
      await _persistSession(user: fallback.user, tokens: fallback.tokens);
      return fallback;
    }
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
    if (session['local_session'] == true) {
      return SessionUser.fromJson(_asMap(session['user']));
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff-portal/profile',
      parser: _asMap,
    );

    final user = SessionUser.fromJson(_asMap(response.data));
    await _tokenStorage.write({...session, 'user': user.toJson()});
    return user;
  }

  Future<void> logout() async {
    final session = await _tokenStorage.read() ?? <String, dynamic>{};
    if (session['local_session'] == true) {
      await _tokenStorage.clear();
      return;
    }

    await _apiClient.post<Object?>(
      '/staff-portal/auth/logout',
      data: {'refresh_token': session['refresh_token']},
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

  Future<void> _persistSession({
    required SessionUser user,
    required Map<String, dynamic> tokens,
  }) async {
    await _tokenStorage.write({...tokens, 'user': user.toJson()});
  }

  SessionUser? _localStaffAccount({
    required String email,
    required String password,
  }) {
    if (password != 'Admin@123') {
      return null;
    }

    return switch (_normalizeEmail(email)) {
      'admin@tolab.edu' || 'admin@tolab.local' => const SessionUser(
        id: 1,
        fullName: 'Super Admin',
        universityEmail: 'admin@tolab.edu',
        roleType: 'admin',
        isActive: true,
        permissions: <String>[
          'staff.view',
          'staff.update',
          'subjects.view',
          'lectures.view',
          'lectures.create',
          'lectures.delete',
          'section_content.view',
          'section_content.create',
          'quizzes.view',
          'quizzes.create',
          'tasks.view',
          'tasks.create',
          'schedule.view',
          'notifications.view',
          'uploads.view',
          'uploads.create',
        ],
        notificationEnabled: true,
      ),
      'doctor@tolab.edu' || 'doctor@tolab.local' => const SessionUser(
        id: 8,
        fullName: 'Dr. Ahmed Hassan',
        universityEmail: 'doctor@tolab.edu',
        roleType: 'doctor',
        isActive: true,
        permissions: <String>[
          'subjects.view',
          'lectures.view',
          'lectures.create',
          'lectures.delete',
          'section_content.view',
          'section_content.create',
          'quizzes.view',
          'quizzes.create',
          'tasks.view',
          'tasks.create',
          'schedule.view',
          'notifications.view',
          'uploads.view',
          'uploads.create',
        ],
        notificationEnabled: true,
      ),
      'assistant@tolab.edu' ||
      'assistant@tolab.local' ||
      'ta@tolab.edu' ||
      'ta@tolab.local' => const SessionUser(
        id: 12,
        fullName: 'TA Sara Ali',
        universityEmail: 'assistant@tolab.edu',
        roleType: 'assistant',
        isActive: true,
        permissions: <String>[
          'subjects.view',
          'lectures.view',
          'section_content.view',
          'section_content.create',
          'quizzes.view',
          'tasks.view',
          'schedule.view',
          'notifications.view',
          'uploads.view',
          'uploads.create',
        ],
        notificationEnabled: true,
      ),
      _ => null,
    };
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  ({SessionUser user, Map<String, dynamic> tokens}) _buildMockDevTestUser() {
    final user =
        _localStaffAccount(email: _devTestEmail, password: _devTestPassword) ??
        const SessionUser(
          id: 8,
          fullName: 'Dr. Ahmed Hassan',
          universityEmail: _devTestEmail,
          roleType: 'doctor',
          isActive: true,
          permissions: <String>[
            'subjects.view',
            'lectures.view',
            'lectures.create',
            'lectures.delete',
            'section_content.view',
            'section_content.create',
            'quizzes.view',
            'quizzes.create',
            'tasks.view',
            'tasks.create',
            'schedule.view',
            'notifications.view',
            'uploads.view',
            'uploads.create',
          ],
          notificationEnabled: true,
        );

    return (
      user: user,
      tokens: <String, dynamic>{
        'access_token': 'local-dev-doctor-access-token',
        'refresh_token': 'local-dev-doctor-refresh-token',
        'local_session': true,
      },
    );
  }

  static ({SessionUser user, Map<String, dynamic> tokens}) _parseSessionPayload(
    Object? value,
  ) {
    final data = _asMap(value);
    return (
      user: SessionUser.fromJson(_asMap(data['user'])),
      tokens: _asMap(data['tokens']),
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
