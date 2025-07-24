import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final _google = GoogleSignIn.instance;
  static final _auth = FirebaseAuth.instance;
  static bool _inited = false;

  static Future<void> init() async {
    if (!_inited) {
      await _google.initialize(
        serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
      );
      _inited = true;
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    await init();
    try {
      final acct = await _google.authenticate(scopeHint: ['email']);
      final tokens = acct.authentication;
      final cred = GoogleAuthProvider.credential(
        idToken: tokens.idToken,
        // اعتمادك هنا، فتأكيد الأمان
      );
      return await _auth.signInWithCredential(cred);
    } on GoogleSignInException catch (e) {
      if (e.code.name == 'canceled') return null;
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }
}
