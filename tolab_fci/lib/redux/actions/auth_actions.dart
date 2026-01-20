class LoginWithMicrosoftAction {
  final String? loginHint;
  
  LoginWithMicrosoftAction({this.loginHint});
}

class LoginSuccessAction {
  final String uid;
  final String email;
  final String role;

  LoginSuccessAction(this.uid, this.email, this.role);
}

class LoginFailureAction {
  final String error;
  LoginFailureAction(this.error);
}
