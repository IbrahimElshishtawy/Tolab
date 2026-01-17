import 'package:redux/redux.dart';
import 'package:tolab_fci/features/auth/data/repositories/auth_repository.dart';
import 'package:tolab_fci/redux/state/app_state.dart';

import '../actions/auth_actions.dart';

/// ===============================
/// Auth Middleware
/// ===============================
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
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action); // لازم يعدي الأول

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
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    await authRepository.signOut();
  };
}
