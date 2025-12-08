import 'auth_actions.dart';
import 'auth_state.dart';

AuthState authReducer(AuthState state, dynamic action) {
  if (action is LoginAction) {
    return state.copyWith(isloading: true, errorMessage: null);
  }

  if (action is LoginSuccessAction) {
    return state.copyWith(
      isloading: false,
      isloadingIn: true,
      token: action.token,
    );
  }

  if (action is LoginFailedAction) {
    return state.copyWith(isloading: false, errorMessage: action.message);
  }

  if (action is LogoutAction) {
    return AuthState.initial();
  }

  return state;
}
