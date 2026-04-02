import '../../../core/state/async_state.dart';
import '../state/auth_actions.dart';
import 'auth_state.dart';

AuthState authReducer(AuthState state, dynamic action) {
  switch (action.runtimeType) {
    case LoginRequestedAction:
    case ForgotPasswordRequestedAction:
    case LogoutRequestedAction:
      return state.copyWith(status: ViewStatus.loading, clearError: true);
    case LoginFailedAction:
      return state.copyWith(
        status: ViewStatus.failure,
        error: (action as LoginFailedAction).message,
      );
    default:
      return state;
  }
}
