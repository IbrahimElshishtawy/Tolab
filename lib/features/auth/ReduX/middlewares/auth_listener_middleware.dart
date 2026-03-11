import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

import 'package:tolab_fci/features/auth/data/auth_roles.dart';
import 'package:tolab_fci/features/auth/data/datasources/auth_role_ds.dart';
import 'package:tolab_fci/features/auth/ReduX/action/auth_actions.dart';
import 'package:tolab_fci/redux/actions/ui_actions.dart';
import 'package:tolab_fci/redux/state/app_state.dart';

Middleware<AppState> createAuthListenerMiddleware(
  FirebaseAuth firebaseAuth,
  AuthRoleDataSource roleDataSource,
) {
  StreamSubscription<User?>? subscription;

  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    // 🔐 نعمل subscribe مرة واحدة فقط
    subscription ??= firebaseAuth.authStateChanges().listen((user) async {
      if (kDebugMode) {
        debugPrint(
          '🔥 AUTH LISTENER fired. user=${user?.uid} email=${user?.email}',
        );
      }

      // ===============================
      // 🚪 User Logged Out
      // ===============================
      if (user == null) {
        if (store.state.authState.isAuthenticated) {
          store.dispatch(LogoutAction());
          store.dispatch(ShowSplashAction());
        }
        return;
      }

      // ===============================
      // 📧 Check University Email
      // ===============================
      final email = (user.email ?? '').toLowerCase().trim();

      if (!email.endsWith('tanta.edu.eg') &&
          !email.endsWith('fci.helwan.edu.eg')) {
        store.dispatch(
          LoginFailureAction('يجب استخدام البريد الإلكتروني الجامعي فقط'),
        );
        await firebaseAuth.signOut();
        return;
      }

      // ===============================
      // 🧠 Prevent duplicate dispatch
      // ===============================
      final authState = store.state.authState;

      final alreadyAuthenticated =
          authState.isAuthenticated &&
          authState.uid == user.uid &&
          authState.role != null &&
          authState.role!.isNotEmpty;

      if (alreadyAuthenticated) {
        if (kDebugMode) {
          debugPrint('ℹ️ User already authenticated – skip dispatch');
        }
        return;
      }

      // ===============================
      // 🧑‍🎓 Resolve Role from Firestore
      // ===============================
      try {
        final role = await roleDataSource.resolveUserRole(
          user,
          AuthRoles.defaultDeveloperRole,
        );

        if (kDebugMode) {
          debugPrint('🔥 ROLE RESOLVED = $role');
        }

        store.dispatch(LoginSuccessAction(user.uid, email, role));

        // ✅ إخفاء Splash / Intro بعد نجاح الدخول
        store.dispatch(HideSplashAction());
        store.dispatch(HideIntroAction());

        if (kDebugMode) {
          debugPrint(
            '✅ DISPATCHED LoginSuccessAction uid=${user.uid} role=$role',
          );
        }
      } catch (e, stack) {
        if (kDebugMode) {
          debugPrint('❌ ROLE ERROR: $e');
          debugPrint('$stack');
        }

        store.dispatch(LoginFailureAction('فشل تحميل بيانات المستخدم'));

        await firebaseAuth.signOut();
      }
    });
  };
}
