import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _google = GoogleSignIn.instance;

  static Future<UserCredential> signInWithGoogle() async {
    await _google.initialize(); // required

    GoogleSignInAccount account;
    try {
      account = await _google.authenticate(scopeHint: ['email']);
    } on GoogleSignInException catch (e) {
      throw FirebaseAuthException(code: 'CANCELLED', message: e.description);
    }

    final GoogleSignInAuthentication auth = account.authentication;
    final cred = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      // accessToken: auth.accessToken,
    );
    return await _auth.signInWithCredential(cred);
  }

  static Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }
}
