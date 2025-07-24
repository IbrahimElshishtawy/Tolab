// ignore_for_file: unnecessary_null_comparison, unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 📌 تأكد من وضع الـ Web client ID الصحيح هنا
const String _webClientId =
    '168050637950-la7d6jh8f4ahh90f6pulndhkbi1bmi95.apps.googleusercontent.com';

class GoogleSignInService {
  static final _google = GoogleSignIn.instance;
  static final _auth = FirebaseAuth.instance;
  static bool _inited = false;

  BuildContext get context =>
      throw UnimplementedError('context is not implemented');

  static Future<void> init() async {
    if (!_inited) {
      await _google.initialize(serverClientId: _webClientId);
      _inited = true;
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    await init();
    try {
      final acct = await _google.authenticate(); // طريقة موثوقة للدخول
      if (acct == null) return null;

      final auth = await acct.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        // accessToken اختياري
      );
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final userCredential = await GoogleSignInService.signInWithGoogle();
      if (userCredential == null) return; // إذا ألغى المستخدم النافذة

      // تم تسجيل الدخول بنجاح
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (kDebugMode) print('فشل تسجيل الدخول: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تسجيل الدخول بواسطة Google')),
        );
      }
    }
  }
}
