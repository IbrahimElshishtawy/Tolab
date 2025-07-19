import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;
  String? errorMessage;

  /// تسجيل الدخول
  Future<bool> login() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final email = emailController.text.trim();
    final password = passwordController.text;

    // مثال بسيط للتحقق
    await Future.delayed(
      const Duration(seconds: 2),
    ); // محاكاة عملية تسجيل الدخول

    if (email == "test@ics.tanta.edu.eg" && password == "123456") {
      if (rememberMe) {
        await saveLoginData(email);
      }

      isLoading = false;
      notifyListeners();
      return true;
    } else {
      errorMessage = "البريد الإلكتروني أو كلمة المرور غير صحيحة.";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// حفظ بيانات تسجيل الدخول
  Future<void> saveLoginData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', email);
  }

  /// التحقق من حالة تسجيل الدخول عند تشغيل التطبيق
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// تغيير حالة "تذكرني"
  void toggleRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  /// تنظيف البيانات
  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }
}
