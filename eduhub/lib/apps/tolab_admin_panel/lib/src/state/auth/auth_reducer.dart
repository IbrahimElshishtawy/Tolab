import 'auth_state.dart';
import 'auth_actions.dart';

AuthState authReducer(AuthState state, dynamic action) {
  if (action is LoginAction) {
    return state.copyWith(isloading: true, errorMessage: null);
  }

  if (action is LoginSuccessAction) {
    return state.copyWith(
      isloading: false,
      isloadingIn: true,
      token: action.token,
      errorMessage: null,
    );
  }

  if (action is LoginFailedAction) {
    return state.copyWith(
      isloading: false,
      isloadingIn: false,
      errorMessage: action.error,
    );
  }

  return state;
}
