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
Middleware<AppState> _loginMiddleware(AuthRepository authRepository) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    final email = action.emailHint.trim();

    // Validation: الإيميل فاضي
    if (email.isEmpty) {
      store.dispatch(
        const LoginFailureAction('من فضلك أدخل البريد الإلكتروني الجامعي'),
      );
      return;
    }

    // Validation: صيغة الإيميل
    if (!_isValidEmail(email)) {
      store.dispatch(
        const LoginFailureAction('صيغة البريد الإلكتروني غير صحيحة'),
      );
      return;
    }

    //  Validation: دومين جامعي
    if (!_isUniversityEmail(email)) {
      store.dispatch(
        const LoginFailureAction('يجب استخدام البريد الإلكتروني الجامعي'),
      );
      return;
    }

    try {
      // Microsoft Login
      final result = await authRepository.signInWithMicrosoft(
        action.selectedRole,
      );

      store.dispatch(
        LoginSuccessAction(
          uid: result.uid,
          email: result.email,
          role: result.role,
        ),
      );
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
  final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

bool _isUniversityEmail(String email) {
  // عدّل الدومين هنا حسب جامعتك
  const allowedDomains = ['tanta.edu.eg'];

  final domain = email.split('@').last.toLowerCase();
  return allowedDomains.contains(domain);
}
