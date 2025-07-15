// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// ✅ تسجيل مستخدم جديد
  static Future<AuthResponse?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        // 📌 ضيف redirect link لو مفعّل تحقق البريد في Supabase
        emailRedirectTo: 'myapp://login-callback',
      );
      if (kDebugMode) {
        print("✅ User created: ${response.user?.email}");
      }
      return response;
    } on AuthException catch (e) {
      if (kDebugMode) {
        print("❌ AuthException in signUp: ${e.message}");
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Unknown error in signUp: $e");
      }
      return null;
    }
  }

  /// ✅ تسجيل الدخول
  static Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (kDebugMode) {
        print("✅ Logged in as: ${response.user?.email}");
      }
      return response;
    } on AuthException catch (e) {
      if (kDebugMode) {
        print("❌ AuthException in signIn: ${e.message}");
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Unknown error in signIn: $e");
      }
      return null;
    }
  }

  /// ✅ تسجيل الخروج
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      if (kDebugMode) {
        print("✅ User signed out.");
      }
    } catch (e) {
      print("❌ Error signing out: $e");
    }
  }

  /// ✅ إرسال رابط إعادة تعيين كلمة المرور
  static Future<void> sendResetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      print("✅ Password reset link sent.");
    } on AuthException catch (e) {
      print("❌ AuthException in resetPassword: ${e.message}");
    } catch (e) {
      print("❌ Unknown error in resetPassword: $e");
    }
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
