// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential> signInWithGoogle() async {
    try {
      // 1. إنشاء كائن GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // 2. بدء عملية تسجيل الدخول
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // 3. التحقق إن المستخدم اختار حساب
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'تم إلغاء تسجيل الدخول من قبل المستخدم.',
        );
      }

      // 4. الحصول على التوكين
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 5. إنشاء بيانات الاعتماد (Credential)
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 6. تسجيل الدخول إلى Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('❌ حدث خطأ أثناء تسجيل الدخول باستخدام Google: $e');
      rethrow;
    }
  }

  static Future<void> signOutFromGoogle() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      print('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      print('❌ خطأ أثناء تسجيل الخروج: $e');
    }
  }

  static User? get currentUser => _auth.currentUser;

  static Future<GoogleSignInAccount?> mySignIn() async {
    if (someCondition) {
      return await GoogleSignIn().signIn();
    }
    // الحل: أضف throw أو return null أو قيمة مناسبة
    throw Exception('لم يتم تسجيل الدخول');
  }
}
