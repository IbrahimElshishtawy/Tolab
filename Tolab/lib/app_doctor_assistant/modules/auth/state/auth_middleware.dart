import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/auth_repository.dart';
import 'auth_actions.dart';
import 'session_actions.dart';

List<Middleware<DoctorAssistantAppState>> createAuthMiddleware(
  AuthRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoginRequestedAction>(
      _login(repository),
    ),
    TypedMiddleware<DoctorAssistantAppState, ForgotPasswordRequestedAction>(
      _forgotPassword(repository),
    ),
    TypedMiddleware<DoctorAssistantAppState, LogoutRequestedAction>(
      _logout(repository),
    ),
  ];
}

Middleware<DoctorAssistantAppState> _login(AuthRepository repository) {
  return (store, action, next) async {
    next(action);
    try {
      final loginAction = action as LoginRequestedAction;
      final result = await repository.login(
        email: loginAction.email,
        password: loginAction.password,
      );
      store.dispatch(SessionEstablishedAction(result.user));
    } catch (error) {
      store.dispatch(LoginFailedAction(error.toString()));
    }
  };
}

Middleware<DoctorAssistantAppState> _forgotPassword(AuthRepository repository) {
  return (store, action, next) async {
    next(action);
    try {
      await repository.forgotPassword(
        (action as ForgotPasswordRequestedAction).email,
      );
    } catch (error) {
      store.dispatch(LoginFailedAction(error.toString()));
    }
  };
}

Middleware<DoctorAssistantAppState> _logout(AuthRepository repository) {
  return (store, action, next) async {
    next(action);
    await repository.logout();
    store.dispatch(const SessionClearedAction());
  };
}
