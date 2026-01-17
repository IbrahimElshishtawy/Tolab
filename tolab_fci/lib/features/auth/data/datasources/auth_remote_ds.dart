import 'package:firebase_auth/firebase_auth.dart';

/// ===============================
/// Auth Remote Data Source
/// Firebase Authentication Only
/// ===============================
abstract class AuthRemoteDataSource {
  /// تسجيل الدخول باستخدام Microsoft
  Future<UserCredential> signInWithMicrosoft();

  /// user الحالي
  User? getCurrentUser();

  /// sign out
  Future<void> signOut();
}

/// ===============================
/// Implementation
/// ===============================
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl(this._firebaseAuth);

  @override
  Future<UserCredential> signInWithMicrosoft() async {
    try {
      final microsoftProvider = OAuthProvider('microsoft.com');

      microsoftProvider.setScopes(['openid', 'email', 'profile']);

      final userCredential = await _firebaseAuth.signInWithProvider(
        microsoftProvider,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Microsoft sign-in failed');
    } catch (e) {
      throw Exception('Unexpected error during Microsoft sign-in');
    }
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
