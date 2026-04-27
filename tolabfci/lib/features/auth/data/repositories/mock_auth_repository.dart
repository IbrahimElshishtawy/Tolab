import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/mock_backend_service.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/state/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(
    backendService: ref.watch(mockBackendServiceProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
    preferencesService: ref.watch(preferencesServiceProvider),
  );
});

class MockAuthRepository implements AuthRepository {
  const MockAuthRepository({
    required MockBackendService backendService,
    required SecureStorageService secureStorageService,
    required PreferencesService preferencesService,
  }) : _backendService = backendService,
       _secureStorageService = secureStorageService,
       _preferencesService = preferencesService;

  final MockBackendService _backendService;
  final SecureStorageService _secureStorageService;
  final PreferencesService _preferencesService;

  @override
  Future<AuthSessionData> login({
    required String email,
    required String password,
  }) async {
    final session = await _backendService.login(
      email: email,
      password: password,
    );
    await _secureStorageService.write(StorageKeys.authToken, session.token);
    await _preferencesService.setString(
      StorageKeys.currentUserRole,
      session.role.storageValue,
    );
    await _secureStorageService.write(
      StorageKeys.pendingNationalId,
      session.nationalId,
    );
    await _preferencesService.setBool(StorageKeys.hasVerifiedNationalId, false);
    return session;
  }

  @override
  Future<(AuthStage, AppUserRole, String?)> restoreSession() async {
    final token = await _secureStorageService.read(StorageKeys.authToken);
    final role = AppUserRole.fromStorage(
      _preferencesService.getString(StorageKeys.currentUserRole),
    );
    if (token == null || token.isEmpty) {
      return (AuthStage.unauthenticated, role, null);
    }
    final hasVerified = _preferencesService.getBool(
      StorageKeys.hasVerifiedNationalId,
    );
    final pendingNationalId = hasVerified
        ? null
        : await _secureStorageService.read(StorageKeys.pendingNationalId);
    return (
      hasVerified ? AuthStage.authenticated : AuthStage.awaitingNationalId,
      role,
      pendingNationalId,
    );
  }

  @override
  Future<void> verifyNationalId(
    String nationalId, {
    required String expectedNationalId,
  }) async {
    await _backendService.verifyNationalId(
      nationalId,
      expectedNationalId: expectedNationalId,
    );
    await _preferencesService.setBool(StorageKeys.hasVerifiedNationalId, true);
    await _secureStorageService.delete(StorageKeys.pendingNationalId);
  }

  @override
  Future<void> logout() async {
    await _secureStorageService.deleteAll();
    await _preferencesService.setBool(StorageKeys.hasVerifiedNationalId, false);
    await _preferencesService.setString(
      StorageKeys.currentUserRole,
      AppUserRole.student.storageValue,
    );
  }
}
