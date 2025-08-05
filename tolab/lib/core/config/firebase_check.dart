import 'package:firebase_auth/firebase_auth.dart';

class FirebaseCheck {
  /// ✅ التحقق إذا كان البريد الإلكتروني مسجلاً في Firebase
  static Future<bool> checkEmailExists(String email) async {
    try {
      // نحاول تسجيل الدخول بحساب غير موجود (أو كلمة مرور فارغة) لنكشف إذا كان موجود مسبقاً
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: 'dummy_password', // أي كلمة مرور وهمية
      );
      return true; // نجح تسجيل الدخول ⇒ البريد موجود
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false; // البريد غير موجود
      } else if (e.code == 'wrong-password') {
        return true; // البريد موجود ولكن كلمة المرور خطأ ⇒ موجود
      } else {
        throw Exception('خطأ غير متوقع: ${e.message}');
      }
    }
  }

  /// ✅ إرسال رابط إعادة تعيين كلمة المرور
  static Future<String?> sendResetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null; // نجاح
    } on FirebaseAuthException catch (e) {
      return 'فشل إرسال الرابط: ${e.message}';
    } catch (e) {
      return 'خطأ غير متوقع: $e';
    }
  }
}
