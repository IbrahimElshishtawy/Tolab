import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/redux/actions/auth_actions.dart';
import 'package:tolab_fci/redux/state/app_state.dart';

List<Middleware<AppState>> createAuthMiddleware(dynamic repository) {
  return [authMiddleware];
}

String detectRoleFromEmail(String email) {
  // Extract domain from email
  final domain = email.split('@')[1];

  // Determine role based on email domain or pattern
  if (domain == 'fci.helwan.edu.eg') {
    return 'student';
  } else if (domain == 'admin.fci.helwan.edu.eg') {
    return 'admin';
  } else if (domain == 'faculty.fci.helwan.edu.eg') {
    return 'instructor';
  }

  return 'guest';
}

void authMiddleware(
  Store<AppState> store,
  dynamic action,
  NextDispatcher next,
) async {
  if (action is LoginWithMicrosoftAction) {
    next(action);

    try {
      final provider = OAuthProvider("microsoft.com");
      provider.setCustomParameters({
        "tenant": "common",
        if (action.loginHint != null) "login_hint": action.loginHint!,
      });
      provider.addScope('email');
      provider.addScope('User.Read');

      // 🔐 تسجيل الدخول
      final credential = await FirebaseAuth.instance.signInWithProvider(
        provider,
      );

      final user = credential.user!;
      final uid = user.uid;
      final email = user.email ?? action.loginHint ?? "";

      if (email.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-email',
          message: 'No email provided by provider',
        );
      }

      // 🔎 Firestore role check
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      String role;

      if (!doc.exists) {
        role = detectRoleFromEmail(email);

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        role = doc['role'];
      }

      store.dispatch(LoginSuccessAction(uid, email, role));
    } catch (e) {
      store.dispatch(LoginFailureAction(e.toString()));
    }
  }

  next(action);
}
