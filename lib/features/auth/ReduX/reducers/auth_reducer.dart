import '../action/auth_actions.dart';
import '../states/auth_state.dart';

/// ===============================
/// Initial Auth State
/// ===============================
final AuthState initialAuthState = AuthState(
  isAuthenticated: false,
  isLoading: false,
  uid: null,
  email: null,
  role: null,
  error: null,
);

/// ===============================
/// Auth Reducer
/// ===============================
AuthState authReducer(AuthState state, dynamic action) {
  if (action is LoginLoadingAction) {
    return state.copyWith(
      isAuthenticated: state.isAuthenticated,
      isLoading: true,
      error: '',
    );
  }

  if (action is LoginStopLoadingAction) {
    return state.copyWith(
      isAuthenticated: state.isAuthenticated,
      isLoading: false,
      error: '',
    );
  }

  if (action is EmailNotRegisteredAction) {
    return state.copyWith(
      isAuthenticated: false,
      isLoading: false,
      error: action.message,
    );
  }
  if (action is LoginSuccessAction) {
    return state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      uid: action.uid,
      email: action.email,
      role: action.role,
      error: '',
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
    return initialAuthState;
  }

  if (action is ResetAuthStateAction) {
    return initialAuthState;
  }

  return state;
}
