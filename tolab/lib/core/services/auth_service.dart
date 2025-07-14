// lib/core/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// ✅ تسجيل مستخدم جديد
  static Future<AuthResponse?> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );

    // Supabase يقوم تلقائيًا بإرسال رابط التحقق للبريد الإلكتروني
    return response;
  }

  /// ✅ تسجيل الدخول
  static Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return response;
  }

  /// ✅ تسجيل الخروج
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// ✅ التحقق من حالة تسجيل الدخول
  static bool isLoggedIn() {
    return _client.auth.currentUser != null;
  }

  /// ✅ التحقق من تفعيل البريد الإلكتروني
  static bool isEmailVerified() {
    final user = _client.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  /// ✅ جلب بيانات المستخدم الحالي
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// ✅ جلب UID المستخدم الحالي
  static String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }
}
