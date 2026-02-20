import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<void> signInWithMicrosoft(String selectedRole);
  User? getCurrentUser();
  Future<void> signOut();
}

/// ===============================
/// Auth User Entity (اختياري – للاستخدام الداخلي)
/// ===============================
class AuthUser {
  final String uid;
  final String email;
  final String role;

  const AuthUser({required this.uid, required this.email, required this.role});
}
