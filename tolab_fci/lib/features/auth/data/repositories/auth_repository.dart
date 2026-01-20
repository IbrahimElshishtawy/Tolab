import 'package:firebase_auth/firebase_auth.dart';

/// Auth Repository (Abstract)
/// ===============================
abstract class AuthRepository {
  /// 🔍 فحص هل الإيميل مسجل في النظام الجامعي
  /// (Firestore / DB / API)
  Future<bool> isEmailRegistered(String email);

  /// 🔐 تسجيل الدخول باستخدام Microsoft
  /// Firebase Auth Listener هو المسؤول عن LoginSuccess
  Future<void> signInWithMicrosoft(String selectedRole);

  /// 👤 المستخدم الحالي من Firebase
  User? getCurrentUser();

  /// 🚪 تسجيل الخروج
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
