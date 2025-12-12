class LoginAction {
  final String email;
  final String password;
  LoginAction(this.email, this.password);
}

class LoginSuccessAction {
  final String token;
  final String email;
  LoginSuccessAction({required this.token, required this.email});
}

class LoginFailedAction {
  final String error;
  LoginFailedAction(this.error);
}
