import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  /// تسجيل الدخول باستخدام Microsoft + تحديد الدور
  Future<AuthUser> signInWithMicrosoft(String selectedRole);

  /// المستخدم الحالي
  User? getCurrentUser();

  /// تسجيل الخروج
  Future<void> signOut();
}

/// ===============================
/// Auth User Entity (مبسطة)
/// ===============================
class AuthUser {
  final String uid;
  final String email;
  final String role;

  AuthUser({required this.uid, required this.email, required this.role});
}
