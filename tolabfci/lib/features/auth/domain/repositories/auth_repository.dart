import '../../presentation/state/auth_state.dart';

abstract class AuthRepository {
  Future<AuthStage> restoreSession();

  Future<void> login({required String email, required String password});

  Future<void> verifyNationalId(String nationalId);

  Future<void> logout();
}
