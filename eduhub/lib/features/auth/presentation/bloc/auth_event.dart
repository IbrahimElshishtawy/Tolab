// features/auth/presentation/bloc/auth_event.dart

abstract class AuthEvent {
  const AuthEvent();
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
