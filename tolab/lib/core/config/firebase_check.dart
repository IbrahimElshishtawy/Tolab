// ignore_for_file: deprecated_member_use, avoid_print

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseCheck {
  /// ✅ إرسال رابط إعادة تعيين كلمة المرور
  static Future<String?> sendResetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null; // النجاح
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 'البريد الإلكتروني غير صالح';
      } else if (e.code == 'user-not-found') {
        return 'هذا البريد غير مسجل في Firebase';
      } else {
        return 'حدث خطأ أثناء إرسال الرابط: ${e.message}';
      }
    } catch (e) {
      return 'حدث خطأ غير متوقع: $e';
    }
  }

  /// ✅ التحقق مما إذا كان البريد مسجلاً في Firebase
  static Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        email,
      );
      return methods.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        print('[ERROR] تنسيق الإيميل غير صحيح');
      } else {
        print('[ERROR] خطأ غير معروف: ${e.message}');
      }
      return false;
    }
  }
}
