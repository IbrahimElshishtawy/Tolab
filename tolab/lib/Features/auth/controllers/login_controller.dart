// lib/auth/controllers/login_controller.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tolab/core/services/auth_service.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  bool showPassword = false;

  // ✅ خاصية تذكرني
  bool rememberMe = false;

  /// ✅ تبديل رؤية كلمة المرور
  void toggleShowPassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  /// ✅ تبديل "تذكرني"
  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  /// ✅ تنفيذ تسجيل الدخول
  Future<bool> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'يرجى ملء البريد وكلمة المرور';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.signIn(
        email: email,
        password: password,
      );

      if (response?.user != null) {
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', email);
          await prefs.setString('saved_password', password);
        }

        return true;
      } else {
        errorMessage = 'فشل تسجيل الدخول';
        return false;
      }
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'حدث خطأ غير متوقع';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ تفريغ الموارد
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
