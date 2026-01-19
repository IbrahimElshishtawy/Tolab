import 'package:redux/redux.dart';
import 'package:tolab_fci/features/auth/data/repositories/auth_repository.dart';
import '../actions/auth_actions.dart';
import '../state/app_state.dart';

/// ===============================
/// Auth Middleware
/// ===============================
List<Middleware<AppState>> createAuthMiddleware(AuthRepository authRepository) {
  return [
    TypedMiddleware<AppState, LoginRequestAction>(
      _loginMiddleware(authRepository),
    ).call,
    TypedMiddleware<AppState, LogoutAction>(
      _logoutMiddleware(authRepository),
    ).call,
  ];
}

/// ===============================
/// Login Middleware
/// ===============================

// auth_middleware.dart
Middleware<AppState> _loginMiddleware(AuthRepository authRepository) {
  return (store, action, next) async {
    next(action);

    final email = action.emailHint.trim();

    if (email.isEmpty) {
      store.dispatch(const LoginFailureAction('أدخل البريد الجامعي'));
      return;
    }

    if (!_isValidEmail(email) || !_isUniversityEmail(email)) {
      store.dispatch(const LoginFailureAction('بريد جامعي غير صالح'));
      return;
    }

    try {
      //  فقط افتح Microsoft Login
      await authRepository.signInWithMicrosoft(action.selectedRole);
      // ممنوع LoginSuccess هنا
    } catch (e) {
      store.dispatch(LoginFailureAction(e.toString()));
    }
  };
}

/// ===============================
/// Logout Middleware
/// ===============================
Middleware<AppState> _logoutMiddleware(AuthRepository authRepository) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    await authRepository.signOut();
  };
}

/// ===============================
/// Helpers
/// ===============================

bool _isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
  return emailRegex.hasMatch(email);
}

bool _isUniversityEmail(String email) {
  const allowedRootDomain = 'tanta.edu.eg';

  final domain = email.split('@').last.toLowerCase();
  return domain.endsWith(allowedRootDomain);
}
