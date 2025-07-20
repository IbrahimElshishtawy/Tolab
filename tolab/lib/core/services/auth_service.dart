import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> register(String email, String password) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCred.user;
  }

  Future<User?> login(String email, String password) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCred.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get userChanges => _auth.authStateChanges();

  /// ✅ إرسال رابط إعادة تعيين كلمة المرور
  static Future<void> sendResetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  /// ✅ التأكد من التحقق من البريد
  static bool isEmailVerified() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.emailVerified ?? false;
  }

  /// ✅ تسجيل مستخدم جديد
  static Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return credential.user;
  }

  /// ✅ تسجيل الدخول
  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }
}
