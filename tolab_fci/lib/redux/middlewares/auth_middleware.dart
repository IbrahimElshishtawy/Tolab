import 'package:redux/redux.dart';
import 'package:tolab_fci/features/auth/data/repositories/auth_repository.dart';
import '../actions/auth_actions.dart';
import '../state/app_state.dart';

List<Middleware<AppState>> createAuthMiddleware(AuthRepository authRepository) {
  return [
    TypedMiddleware<AppState, LoginRequestAction>(
      _loginMiddleware(authRepository),
    ).call,
    TypedMiddleware<AppState, LogoutAction>(
      _logoutMiddleware(authRepository),
    ).call,
  ];
}

/// ===============================
/// Login Middleware
/// ===============================
Middleware<AppState> _loginMiddleware(AuthRepository authRepository) {
  return (store, action, next) async {
    if (store.state.authState.isLoading) return;
    next(action);

    try {
      final result = await authRepository.signInWithMicrosoft(
        action.selectedRole,
      );

      store.dispatch(
        LoginSuccessAction(
          uid: result.uid,
          email: result.email,
          role: result.role,
        ),
      );
    } catch (e) {
      store.dispatch(LoginFailureAction(e.toString()));
    }
  };
}

/// ===============================
/// Logout Middleware
/// ===============================
Middleware<AppState> _logoutMiddleware(AuthRepository authRepository) {
  return (store, action, next) async {
    next(action);
    await authRepository.signOut();
  };
}
