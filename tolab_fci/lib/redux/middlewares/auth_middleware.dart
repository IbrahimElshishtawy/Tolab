import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/redux/actions/auth_actions.dart';
import 'package:tolab_fci/redux/state/app_state.dart';

List<Middleware<AppState>> createAuthMiddleware(dynamic repository) {
  return [authMiddleware];
}

/// 🔎 تحديد الدور من الإيميل
String detectRoleFromEmail(String email) {
  final domain = email.split('@').last;

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
    // مرّر الأكشن أولاً
    next(action);

    try {
      final provider = OAuthProvider("microsoft.com");

      provider.setCustomParameters({
        "tenant": "common",
        if (action.loginHint != null) "login_hint": action.loginHint!,
      });

      provider.addScope('email');
      provider.addScope('User.Read');

      // 🔐 تسجيل الدخول بـ Microsoft
      final credential = await FirebaseAuth.instance.signInWithProvider(
        provider,
      );

      final user = credential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'No user returned from provider',
        );
      }

      final uid = user.uid;
      final email = user.email ?? action.loginHint ?? '';

      if (email.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-email',
          message: 'No email provided by provider',
        );
      }

      // 🔎 فحص الدور في Firestore
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      final doc = await userRef.get();

      String role;

      if (!doc.exists) {
        role = detectRoleFromEmail(email);

        await userRef.set({
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        role = doc['role'];
      }
      store.dispatch(LoginSuccessAction(uid, email, role));
    } catch (e) {
      final message = e.toString();
      if (message.contains('ERROR_WEB_CONTEXT_CANCELED')) {
        store.dispatch(LoginFailureAction('User cancelled login'));
        return;
      }
      store.dispatch(LoginFailureAction(message));
    }

    return;
  }
  next(action);
}
