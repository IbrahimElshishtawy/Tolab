import 'package:flutter/foundation.dart';

/// ===============================
/// Base Auth Action
/// ===============================
@immutable
abstract class AuthAction {
  const AuthAction();
}

/// ===============================
/// Login Flow Actions
/// ===============================

class CheckEmailBeforeMicrosoftLoginAction extends AuthAction {
  final String email;
  final String selectedRole; // student | doctor | ta | it

  const CheckEmailBeforeMicrosoftLoginAction({
    required this.email,
    required this.selectedRole,
  });
}

class LoginLoadingAction extends AuthAction {
  const LoginLoadingAction();
}

class LoginStopLoadingAction extends AuthAction {
  const LoginStopLoadingAction();
}

class LoginSuccessAction extends AuthAction {
  final String uid;
  final String email;
  final String role;

  const LoginSuccessAction({
    required this.uid,
    required this.email,
    required this.role,
  });
}

class LoginFailureAction extends AuthAction {
  final String error;

  const LoginFailureAction(this.error);
}

class EmailNotRegisteredAction extends AuthAction {
  final String message;

  const EmailNotRegisteredAction(this.message);
}

/// ===============================
/// Logout Actions
/// ===============================

class LogoutAction extends AuthAction {
  const LogoutAction();
}

/// ===============================
/// Auth State Reset (اختياري)
/// ===============================
class ResetAuthStateAction extends AuthAction {
  const ResetAuthStateAction();
}
