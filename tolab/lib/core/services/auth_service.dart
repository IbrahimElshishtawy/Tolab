// ignore_for_file: await_only_futures, strict_top_level_inference, unnecessary_null_in_if_null_operators

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance; // ✅ Constructor صحيح

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          (await _googleSignIn.authenticationEvents.firstWhere(
                (event) => event.type == GoogleSignInEventType.signIn,
              ))
              as GoogleSignInAccount?;

      if (googleUser == null) {
        throw Exception('تم إلغاء تسجيل الدخول من قبل المستخدم');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

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
    await _googleSignIn.signOut();
  }

  Stream<User?> get userChanges => _auth.authStateChanges();

  static Future<void> sendResetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static bool isEmailVerified() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.emailVerified ?? false;
  }

  static Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return credential.user;
  }

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

extension on GoogleSignInAuthenticationEvent {
  get type =>
      null ?? GoogleSignInEventType.authentication; // ✅ استخدام النوع الصحيح
}

class GoogleSignInEventType {
  static const signIn = 'signIn';
  static const signOut = 'signOut';
  static const disconnect = 'disconnect';
  static const authentication = 'authentication';
}
