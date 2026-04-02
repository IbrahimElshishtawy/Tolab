class LoginRequestedAction {
  LoginRequestedAction({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class LoginFailedAction {
  LoginFailedAction(this.message);

  final String message;
}

class ForgotPasswordRequestedAction {
  ForgotPasswordRequestedAction(this.email);

  final String email;
}

class LogoutRequestedAction {}
