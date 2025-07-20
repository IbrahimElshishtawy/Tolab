import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;
  String? errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// تسجيل الدخول باستخدام Firebase Auth
  Future<bool> login() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
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

  /// التحقق من حالة تسجيل الدخول (المستخدم الحالي)
  bool checkLoginStatus() {
    return _auth.currentUser != null;
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
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
