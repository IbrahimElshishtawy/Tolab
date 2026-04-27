import '../../../../core/session/app_session.dart';
import '../../presentation/state/auth_state.dart';

abstract class AuthRepository {
  Future<(AuthStage, AppUserRole, String?)> restoreSession();

  Future<AuthSessionData> login({
    required String email,
    required String password,
  });

  Future<void> verifyNationalId(
    String nationalId, {
    String? expectedNationalId,
  });

  Future<void> logout();
}
