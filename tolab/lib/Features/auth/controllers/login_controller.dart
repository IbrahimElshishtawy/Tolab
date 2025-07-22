// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;
  String? errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// تسجيل الدخول باستخدام Firebase Auth
  Future<bool> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // حفظ حالة الدخول إذا كان rememberMe مفعّل
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }

      // ✅ التنقل إلى الصفحة الرئيسية
      Navigator.pushReplacementNamed(context, '/home');

      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = 'هذا البريد غير مسجل.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور غير صحيحة.';
      } else {
        errorMessage = 'حدث خطأ أثناء تسجيل الدخول.';
      }
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  /// التحقق من حالة تسجيل الدخول
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('isLoggedIn') ?? false;
    final userLogged = _auth.currentUser != null;

    return saved && userLogged;
  }

  /// تسجيل الخروج
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacementNamed(context, '/login');
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
