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
    final provider = OAuthProvider('microsoft.com');

    provider.setScopes(['openid', 'email', 'profile']);

    provider.setCustomParameters({
      'tenant': 'organizations', // مهم للإيميل الجامعي
    });

    return await FirebaseAuth.instance.signInWithProvider(provider);
  }

  @override
  User? getCurrentUser() => _firebaseAuth.currentUser;

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}
