import 'package:redux/redux.dart';
import 'package:tolab_fci/features/auth/data/repositories/auth_repository.dart';
import '../actions/auth_actions.dart';
import '../state/app_state.dart';

/// ===============================
/// Auth Middleware
/// ===============================
List<Middleware<AppState>> createAuthMiddleware(AuthRepository authRepository) {
  return [
    TypedMiddleware<AppState, CheckEmailBeforeMicrosoftLoginAction>(
      _checkEmailAndLoginMiddleware(authRepository),
    ).call,

    TypedMiddleware<AppState, LogoutAction>(
      _logoutMiddleware(authRepository),
    ).call,
  ];
}

/// ===============================
/// Check Email + Microsoft Login
/// ===============================
Middleware<AppState> _checkEmailAndLoginMiddleware(
  AuthRepository authRepository,
) {
  return (store, action, next) async {
    next(action);
    if (action is! CheckEmailBeforeMicrosoftLoginAction) return;
    if (store.state.authState.isLoading) return;

    try {
      store.dispatch(const LoginLoadingAction());
      final exists = await authRepository.isEmailRegistered(action.email);

      if (!exists) {
        store.dispatch(
          const EmailNotRegisteredAction(
            'هذا البريد غير مسجل في النظام الجامعي',
          ),
        );

        store.dispatch(const LoginStopLoadingAction());
        return;
      }
      await authRepository.signInWithMicrosoft(action.selectedRole);
    } catch (e) {
      store.dispatch(
        const LoginFailureAction('حدث خطأ أثناء تسجيل الدخول، حاول مرة أخرى'),
      );

      store.dispatch(const LoginStopLoadingAction());
    }
  };
}

/// ===============================
/// Logout Middleware
/// ===============================
Middleware<AppState> _logoutMiddleware(AuthRepository authRepository) {
  return (store, action, next) async {
    next(action);

    if (action is LogoutAction) {
      await authRepository.signOut();
    }
  };
}
