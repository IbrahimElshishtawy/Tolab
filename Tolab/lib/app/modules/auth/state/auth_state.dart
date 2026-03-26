import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/auth_models.dart';
import '../../../state/app_state.dart';

class AuthState {
  const AuthState({
    this.status = LoadStatus.initial,
    this.currentUser,
    this.errorMessage,
    this.rememberSession = true,
  });

  final LoadStatus status;
  final UserProfile? currentUser;
  final String? errorMessage;
  final bool rememberSession;

  bool get isAuthenticated => currentUser != null;

  AuthState copyWith({
    LoadStatus? status,
    UserProfile? currentUser,
    String? errorMessage,
    bool? rememberSession,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      currentUser: clearUser ? null : currentUser ?? this.currentUser,
      errorMessage: errorMessage ?? this.errorMessage,
      rememberSession: rememberSession ?? this.rememberSession,
    );
  }
}

class LoginSubmittedAction {
  LoginSubmittedAction({
    required this.email,
    required this.password,
    required this.rememberSession,
  });

  final String email;
  final String password;
  final bool rememberSession;
}

class LoginSucceededAction {
  LoginSucceededAction(this.user, {required this.rememberSession});

  final UserProfile user;
  final bool rememberSession;
}

class LoginFailedAction {
  LoginFailedAction(this.message);

  final String message;
}

class HydrateUserAction {
  HydrateUserAction(this.user);

  final UserProfile user;
}

class LogoutRequestedAction {}

class LogoutCompletedAction {}

AuthState authReducer(AuthState state, dynamic action) {
  switch (action) {
    case LoginSubmittedAction():
      return state.copyWith(status: LoadStatus.loading, errorMessage: null);
    case LoginSucceededAction():
      return state.copyWith(
        status: LoadStatus.success,
        currentUser: action.user,
        rememberSession: action.rememberSession,
        errorMessage: null,
      );
    case LoginFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    case HydrateUserAction():
      return state.copyWith(
        status: LoadStatus.success,
        currentUser: action.user,
        errorMessage: null,
      );
    case LogoutCompletedAction():
      return const AuthState(status: LoadStatus.initial);
    default:
      return state;
  }
}

List<Middleware<AppState>> createAuthMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoginSubmittedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final (tokens, user) = await deps.authRepository.login(
          email: action.email,
          password: action.password,
        );
        await deps.authService.persistTokens(tokens);
        store.dispatch(
          LoginSucceededAction(user, rememberSession: action.rememberSession),
        );
      } catch (error) {
        store.dispatch(LoginFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, LogoutRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await deps.authService.clearSession();
      store.dispatch(LogoutCompletedAction());
    }).call,
  ];
}
