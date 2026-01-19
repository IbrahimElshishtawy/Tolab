import 'package:firebase_auth/firebase_auth.dart';
import 'package:redux/redux.dart';
import '../actions/auth_actions.dart';
import '../state/app_state.dart';

Middleware<AppState> createAuthListenerMiddleware(FirebaseAuth firebaseAuth) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    firebaseAuth.authStateChanges().listen((user) {
      if (user == null) {
        if (store.state.authState.isAuthenticated) {
          store.dispatch(const LogoutAction());
        }
        return;
      }
      if (store.state.authState.isAuthenticated) return;
      store.dispatch(
        LoginSuccessAction(
          uid: user.uid,
          email: user.email ?? '',
          role: store.state.authState.role ?? 'student',
        ),
      );
    });
  };
}
