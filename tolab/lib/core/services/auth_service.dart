import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // تسجيل مستخدم جديد
  static Future<AuthResponse?> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );
    return response;
  }

  // تسجيل الدخول
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

  // تسجيل الخروج
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// ✅ إرسال رابط إعادة تعيين كلمة المرور
  static Future<void> sendResetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }

  static bool isLoggedIn() {
    return _client.auth.currentUser != null;
  }

  static bool isEmailVerified() {
    final user = _client.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  static String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }
}
