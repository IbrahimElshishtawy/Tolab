// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/core/config/User_Provider.dart';

class AuthController with ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final nationalIdController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;
  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    ageController.clear();
    nationalIdController.clear();
  }

  /// ✅ تسجيل الدخول
  Future<bool> login(BuildContext context) async {
    setLoading(true);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!credential.user!.emailVerified) {
        errorMessage = "يجب تأكيد البريد الإلكتروني أولاً.";
        setLoading(false);
        return false;
      }

      // ✅ تخزين بيانات المستخدم في UserProvider
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).setUser(credential.user);

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _handleFirebaseAuthError(e);
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ إنشاء حساب جديد
  Future<bool> register(BuildContext context) async {
    setLoading(true);
    try {
      if (passwordController.text != confirmPasswordController.text) {
        errorMessage = "كلمة المرور غير متطابقة";
        setLoading(false);
        return false;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // إرسال بريد التفعيل
      await credential.user!.sendEmailVerification();

      // حفظ البيانات في Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
        'age': ageController.text.trim(),
        'national_id': nationalIdController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      // ✅ تخزين بيانات المستخدم في UserProvider
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).setUser(credential.user);

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _handleFirebaseAuthError(e);
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ التعامل مع رسائل الخطأ
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'هذا البريد مسجل بالفعل.';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً.';
      case 'user-not-found':
        return 'المستخدم غير موجود.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}
