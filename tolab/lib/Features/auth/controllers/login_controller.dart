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

  LoginController() {
    _loadSavedCredentials();
  }

  /// تحميل البريد وكلمة المرور المحفوظين
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';
    final savedRememberMe = prefs.getBool('remember_me') ?? false;

    emailController.text = savedEmail;
    passwordController.text = savedPassword;
    rememberMe = savedRememberMe;
    notifyListeners();
  }

  /// تسجيل الدخول باستخدام Firebase Auth
  Future<bool> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // حفظ حالة الدخول وبيانات الحساب إذا كان rememberMe مفعّل
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('saved_email', email);
        await prefs.setString('saved_password', password);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
      }

      Navigator.pushReplacementNamed(context, '/home');

      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = 'هذا البريد غير مسجل.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور غير صحيحة.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'البيانات غير صحيحة أو انتهت صلاحيتها.';
      } else {
        errorMessage = 'حدث خطأ أثناء تسجيل الدخول.';
      }
      isLoading = false;
      notifyListeners();
      return false;
    }
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

  /// تنظيف الكونترولرز
  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }
}
