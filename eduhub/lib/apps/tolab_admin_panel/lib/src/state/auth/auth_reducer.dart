import 'auth_actions.dart';
import 'auth_state.dart';

AuthState authReducer(AuthState state, dynamic action) {
  if (action is LoginAction) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is LoginSuccessAction) {
    return state.copyWith(
      isLoading: false,
      isLoggedIn: true,
      token: action.token,
    );
  }

  if (action is LoginFailedAction) {
    return state.copyWith(isLoading: false, error: action.message);
  }

  if (action is LogoutAction) {
    return AuthState.initial();
  }

  return state;
}
