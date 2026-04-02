import '../../../app_admin/core/services/app_dependencies.dart' as admin_deps;
import '../../../app_admin/modules/auth/services/auth_service.dart';
import '../../../app_admin/shared/models/auth_models.dart';
import '../../../app_doctor_assistant/core/models/session_user.dart';
import '../../../app_doctor_assistant/core/storage/token_storage.dart';
import '../../../app_doctor_assistant/modules/auth/repositories/auth_repository.dart'
    as doctor_auth;
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import '../services/session_storage.dart';

class UnifiedAuthRepository {
  UnifiedAuthRepository({
    required doctor_auth.AuthRepository doctorRepository,
    required admin_deps.AppDependencies adminDependencies,
    required TokenStorage doctorTokenStorage,
    required SessionStorage sessionStorage,
  }) : _doctorRepository = doctorRepository,
       _adminDependencies = adminDependencies,
       _doctorTokenStorage = doctorTokenStorage,
       _sessionStorage = sessionStorage;

  final doctor_auth.AuthRepository _doctorRepository;
  final admin_deps.AppDependencies _adminDependencies;
  final TokenStorage _doctorTokenStorage;
  final SessionStorage _sessionStorage;

  AuthService get _adminAuthService => _adminDependencies.authService;

  Future<AuthSession?> restoreSession() async {
    final unified = await _sessionStorage.read();
    if (unified != null) {
      await _mirrorLegacyStorage(unified);
      return unified;
    }

    final doctorSession = await _restoreFromDoctorStorage();
    if (doctorSession != null) {
      await _sessionStorage.write(doctorSession);
      await _mirrorLegacyStorage(doctorSession);
      return doctorSession;
    }

    final adminSession = await _restoreFromAdminStorage();
    if (adminSession != null) {
      await _sessionStorage.write(adminSession);
      await _mirrorLegacyStorage(adminSession);
      return adminSession;
    }

    return null;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _doctorRepository.login(
        email: email,
        password: password,
      );

      final session = AuthSession(
        user: AuthUser.fromSessionUser(result.user),
        accessToken: result.tokens['access_token']?.toString() ?? '',
        refreshToken: result.tokens['refresh_token']?.toString() ?? '',
        isLocalSession: result.tokens['local_session'] == true,
        source: 'staff_portal',
      );
      await _persistSession(session);
      return session;
    } catch (_) {
      final (tokens, user) = await _adminDependencies.authRepository.login(
        email: email,
        password: password,
      );

      final session = AuthSession(
        user: AuthUser.fromAdminProfile(user),
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        isLocalSession: tokens.accessToken.startsWith('demo-access-token'),
        source: 'admin_portal',
      );
      await _persistSession(session);
      return session;
    }
  }

  Future<void> forgotPassword(String email) {
    return _doctorRepository.forgotPassword(email);
  }

  Future<void> logout() async {
    try {
      await _doctorRepository.logout();
    } catch (_) {}

    await _doctorTokenStorage.clear();
    await _adminAuthService.clearSession();
    await _sessionStorage.clear();
  }

  Future<void> _persistSession(AuthSession session) async {
    await _sessionStorage.write(session);
    await _mirrorLegacyStorage(session);
  }

  Future<void> _mirrorLegacyStorage(AuthSession session) async {
    await _adminAuthService.persistTokens(
      AuthTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );

    await _doctorTokenStorage.write(<String, dynamic>{
      'access_token': session.accessToken,
      'refresh_token': session.refreshToken,
      'local_session': session.isLocalSession,
      'user': session.user.toSessionUser().toJson(),
      'source': session.source,
    });
  }

  Future<AuthSession?> _restoreFromDoctorStorage() async {
    final rawSession = await _doctorTokenStorage.read();
    if (rawSession == null) {
      return null;
    }

    final userJson = _asMap(rawSession['user']);
    if (userJson.isEmpty) {
      return null;
    }

    return AuthSession(
      user: AuthUser.fromSessionUser(SessionUser.fromJson(userJson)),
      accessToken: rawSession['access_token']?.toString() ?? '',
      refreshToken: rawSession['refresh_token']?.toString() ?? '',
      isLocalSession: rawSession['local_session'] == true,
      source: rawSession['source']?.toString() ?? 'legacy_staff_portal',
    );
  }

  Future<AuthSession?> _restoreFromAdminStorage() async {
    final hasSession = await _adminAuthService.hasSession();
    if (!hasSession) {
      return null;
    }

    final accessToken = await _adminDependencies.secureStorage
        .readAccessToken();
    final refreshToken = await _adminDependencies.secureStorage
        .readRefreshToken();
    final user = await _adminAuthService.isDemoSession()
        ? _adminDependencies.demoDataService.adminProfile()
        : await _adminDependencies.authRepository.me();

    return AuthSession(
      user: AuthUser.fromAdminProfile(user),
      accessToken: accessToken ?? '',
      refreshToken: refreshToken ?? '',
      isLocalSession: await _adminAuthService.isDemoSession(),
      source: 'legacy_admin_portal',
    );
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const <String, dynamic>{};
  }
}
