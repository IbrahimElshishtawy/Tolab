import 'auth_state.dart';
import 'auth_actions.dart';

AuthState authReducer(AuthState state, dynamic action) {
  if (action is LoginStartAction) {
    return state.copyWith(isLoading: true, error: null);
  }
  if (action is LoginSuccessAction) {
    return state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      email: action.email,
      role: action.role,
      error: null,
    );
  }
  if (action is LoginFailureAction) {
    return state.copyWith(
      isAuthenticated: false,
      isLoading: false,
      error: action.error,
    );
  }
  if (action is LogoutAction) {
    return AuthState.initial();
  }
  return state;
}
