class LoginAction {
  final String email;
  final String password;

  LoginAction(this.email, this.password);
}

class LoginSuccessAction {
  final String token;

  LoginSuccessAction(this.token);
}

class LoginFailedAction {
  final String message;

  LoginFailedAction(this.message);
}

class LogoutAction {}
