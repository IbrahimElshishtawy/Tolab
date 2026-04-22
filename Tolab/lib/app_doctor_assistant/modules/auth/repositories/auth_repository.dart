import '../../../core/models/session_user.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../services/auth_service.dart';

abstract class AuthRepository {
  Future<({SessionUser user, Map<String, dynamic> tokens})> login({
    required String email,
    required String password,
  });

  Future<({SessionUser user, Map<String, dynamic> tokens})> createDevTestUser();

  Future<SessionUser?> restoreSession();

  Future<SessionUser> fetchCurrentUser();

  Future<void> logout();

  Future<void> forgotPassword(String email);
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._authService, this._tokenStorage);

  static const String _devTestEmail = 'doctor@tolab.edu';
  static const String _devTestPassword = '123456';

  final AuthService _authService;
  final TokenStorage _tokenStorage;

  @override
  Future<({SessionUser user, Map<String, dynamic> tokens})> login({
    required String email,
    required String password,
  }) async {
    final payload = await _authService.login(email: email, password: password);
    await _persistSession(user: payload.user, tokens: payload.tokens);
    return payload;
  }

  @override
  Future<({SessionUser user, Map<String, dynamic> tokens})> createDevTestUser() {
    return login(email: _devTestEmail, password: _devTestPassword);
  }

  @override
  Future<SessionUser?> restoreSession() async {
    final session = await _tokenStorage.read();
    final userJson = _asMap(session?['user']);
    if (userJson.isNotEmpty) {
      return SessionUser.fromJson(userJson);
    }

    return null;
  }

  @override
  Future<SessionUser> fetchCurrentUser() async {
    final session = await _tokenStorage.read() ?? <String, dynamic>{};
    final user = await _authService.fetchCurrentUser();
    await _tokenStorage.write({...session, 'user': user.toJson()});
    return user;
  }

  @override
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

  @override
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

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._tokenStorage, this._mockRepository);

  static const String _devTestEmail = 'doctor@tolab.edu';
  static const String _devTestPassword = '123456';

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<({SessionUser user, Map<String, dynamic> tokens})> login({
    required String email,
    required String password,
  }) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 360));
    final user = _mockRepository.authenticate(email: email, password: password);
    final tokens = <String, dynamic>{
      'access_token': 'mock-access-${user.roleType}-${user.id}',
      'refresh_token': 'mock-refresh-${user.roleType}-${user.id}',
      'local_session': true,
    };
    await _persistSession(user: user, tokens: tokens);
    return (user: user, tokens: tokens);
  }

  @override
  Future<({SessionUser user, Map<String, dynamic> tokens})> createDevTestUser() {
    return login(email: _devTestEmail, password: _devTestPassword);
  }

  @override
  Future<SessionUser?> restoreSession() async {
    final session = await _tokenStorage.read();
    return _mockRepository.restoreUserFromSession(session);
  }

  @override
  Future<SessionUser> fetchCurrentUser() async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 180));
    final session = await _tokenStorage.read();
    final user = _mockRepository.restoreUserFromSession(session);
    if (user == null) {
      throw Exception('No local session found.');
    }
    final refreshedUser = _mockRepository.refreshUser(user);
    await _tokenStorage.write({
      ...?session,
      'user': refreshedUser.toJson(),
      'local_session': true,
    });
    return refreshedUser;
  }

  @override
  Future<void> logout() async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 120));
    await _tokenStorage.clear();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 220));
    if (!_mockRepository.hasAccount(email)) {
      throw Exception('No local mock account found for $email.');
    }
  }

  Future<void> _persistSession({
    required SessionUser user,
    required Map<String, dynamic> tokens,
  }) async {
    await _tokenStorage.write({
      ...tokens,
      'user': user.toJson(),
      'local_session': true,
      'source': 'mock_frontend',
    });
  }
}
