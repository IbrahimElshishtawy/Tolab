import 'package:firebase_auth/firebase_auth.dart';

import 'auth_remote_ds.dart';

/// ===============================
/// Auth Remote Data Source Impl
/// Firebase Authentication Only
/// ===============================
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl(this._firebaseAuth);

  @override
  Future<UserCredential> signInWithMicrosoft() async {
    try {
      final provider = OAuthProvider('microsoft.com');

      provider.setScopes(['openid', 'email', 'profile']);
      provider.setCustomParameters({'tenant': 'organizations'});

      final userCredential = await _firebaseAuth.signInWithProvider(provider);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'فشل تسجيل الدخول عبر Microsoft');
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع أثناء تسجيل الدخول عبر Microsoft');
    }
  }

  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('الإيميل غير مسجل');
        case 'wrong-password':
          throw Exception('كلمة المرور غلط');
        case 'invalid-email':
          throw Exception('الإيميل غير صحيح');
        default:
          throw Exception('فشل تسجيل الدخول');
      }
    }
  }

  @override
  User? getCurrentUser() => _firebaseAuth.currentUser;

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}
