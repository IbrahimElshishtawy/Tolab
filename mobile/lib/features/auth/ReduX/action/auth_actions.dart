class LoginAction {
  final String email;
  final String password;
  final String role;

  LoginAction({required this.email, required this.password, required this.role});
}

class LoginLoadingAction {}

class LoginStopLoadingAction {}

class EmailNotRegisteredAction {
  final String message;
  EmailNotRegisteredAction(this.message);
}

class LoginWithMicrosoftAction {
  final String? loginHint;
  LoginWithMicrosoftAction({this.loginHint});
}

class LoginSuccessAction {
  final String uid;
  final String email;
  final String role;
  final String? token;

  LoginSuccessAction(this.uid, this.email, this.role, {this.token});
}

class LoginFailureAction {
  final String error;
  LoginFailureAction(this.error);
}

class LogoutAction {}

class ResetAuthStateAction {}
