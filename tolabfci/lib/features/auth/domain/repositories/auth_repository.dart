import '../../../../core/session/app_session.dart';
import '../../presentation/state/auth_state.dart';

abstract class AuthRepository {
  Future<(AuthStage, AppUserRole)> restoreSession();

  Future<AppUserRole> login({required String email, required String password});

  Future<void> verifyNationalId(String nationalId);

  Future<void> logout();
}
