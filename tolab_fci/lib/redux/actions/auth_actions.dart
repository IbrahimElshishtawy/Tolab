import 'package:flutter/foundation.dart';

/// ===============================
/// Base Auth Action
/// ===============================
@immutable
abstract class AuthAction {
  const AuthAction();
}

/// ===============================
/// Login Actions
/// ===============================

/// بداية تسجيل الدخول (Microsoft)
class LoginRequestAction extends AuthAction {
  final String selectedRole; // student | doctor | ta | it

  const LoginRequestAction({required this.selectedRole});
}

/// تسجيل الدخول نجح
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

/// تسجيل الدخول فشل
class LoginFailureAction extends AuthAction {
  final String error;

  const LoginFailureAction(this.error);
}

/// ===============================
/// Logout Actions
/// ===============================

/// تسجيل الخروج
class LogoutAction extends AuthAction {
  const LogoutAction();
}

/// ===============================
/// Auth State Reset (اختياري)
/// ===============================

/// إعادة تعيين حالة الـ Auth (مثلاً عند App Restart)
class ResetAuthStateAction extends AuthAction {
  const ResetAuthStateAction();
}
