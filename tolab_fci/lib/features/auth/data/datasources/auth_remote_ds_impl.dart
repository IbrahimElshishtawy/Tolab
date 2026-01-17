import 'package:firebase_auth/firebase_auth.dart';
import 'auth_remote_ds.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl(this._firebaseAuth);

  @override
  Future<UserCredential> signInWithMicrosoft() async {
    final provider = OAuthProvider('microsoft.com');
    provider.setCustomParameters({'prompt': 'select_account'});
    return await _firebaseAuth.signInWithProvider(provider);
  }

  @override
  User? getCurrentUser() => _firebaseAuth.currentUser;

  @override
  Future<void> signOut() async => _firebaseAuth.signOut();
}
