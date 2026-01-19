import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

import 'package:tolab_fci/features/auth/data/datasources/auth_role_ds.dart';
import 'package:tolab_fci/redux/actions/ui_actions.dart';
import '../actions/auth_actions.dart';
import '../state/app_state.dart';

Middleware<AppState> createAuthListenerMiddleware(
  FirebaseAuth firebaseAuth,
  AuthRoleDataSource roleDataSource,
) {
  StreamSubscription<User?>? subscription;

  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    // نبدأ listener مرة واحدة فقط
    subscription ??= firebaseAuth.authStateChanges().listen((user) async {
      if (kDebugMode) {
        print('🔥 AUTH LISTENER fired. user=${user?.uid} email=${user?.email}');
      }

      // 🔐 Logout
      if (user == null) {
        if (store.state.authState.isAuthenticated) {
          store.dispatch(const LogoutAction());
          store.dispatch(ShowSplashAction());
        }
        return;
      }

      final currentUid = store.state.authState.uid;
      final alreadySameUser =
          currentUid == user.uid &&
          store.state.authState.isAuthenticated &&
          store.state.authState.role != null &&
          store.state.authState.role!.isNotEmpty &&
          store.state.authState.role != 'unknown';

      if (alreadySameUser) return;

      try {
        final role = await roleDataSource.resolveUserRole(user, 'student');

        if (kDebugMode) {
          print('🔥 ROLE RESOLVED = $role');
        }

        // ✅ تسجيل الدخول
        store.dispatch(
          LoginSuccessAction(
            uid: user.uid,
            email: (user.email ?? '').toLowerCase(),
            role: role,
          ),
        );
        store.dispatch(HideSplashAction());
        store.dispatch(HideIntroAction());

        if (kDebugMode) {
          print('✅ DISPATCHED LoginSuccessAction uid=${user.uid} role=$role');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ ROLE ERROR: $e');
        }
        store.dispatch(LoginFailureAction(e.toString()));
        store.dispatch(const LogoutAction());
        store.dispatch(ShowSplashAction());
      }
    });
  };
}
