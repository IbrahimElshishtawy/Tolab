// auth_listener_middleware.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';
import '../actions/auth_actions.dart';
import '../state/app_state.dart';

Middleware<AppState> createAuthListenerMiddleware(FirebaseAuth firebaseAuth) {
  return (store, action, next) {
    next(action);

    firebaseAuth.authStateChanges().listen((user) {
      debugPrint('🔥 AUTH LISTENER USER: $user');

      if (user != null && user.email != null) {
        store.dispatch(
          LoginSuccessAction(
            uid: user.uid,
            email: user.email!,
            role: store.state.authState.role ?? 'student',
          ),
        );
      }
    });
  };
}
