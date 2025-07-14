// lib/core/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// تسجيل الدخول
  static Future<AuthResponse> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return response;
  }

  /// إنشاء حساب جديد
  static Future<AuthResponse> signUp(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password.trim(),
    );
    return response;
  }

  /// تسجيل الخروج
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// المستخدم الحالي
  static User? get currentUser => _client.auth.currentUser;

  /// التحقق من الجلسة
  static bool isLoggedIn() => _client.auth.currentSession != null;
}
