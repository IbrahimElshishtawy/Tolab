class LoginAction {
  final String email;
  final String password;
  LoginAction(this.email, this.password);
}

class LoginStartAction {}

class LoginSuccessAction {
  final String email;
  final String role;
  LoginSuccessAction(this.email, this.role);
}

class LoginFailureAction {
  final String error;
  LoginFailureAction(this.error);
}

class LogoutAction {}
