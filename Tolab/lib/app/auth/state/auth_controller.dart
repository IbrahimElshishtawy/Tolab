import 'package:flutter/foundation.dart';

import '../models/auth_session.dart';
import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final UnifiedAuthRepository _repository;

  UnifiedAuthState _state = const UnifiedAuthState();

  UnifiedAuthState get state => _state;

  AuthUser? get currentUser => _state.user;

  AuthSession? get session => _state.session;

  Future<void> bootstrap() async {
    _state = _state.copyWith(
      status: AuthFlowStatus.bootstrapping,
      clearError: true,
    );
    notifyListeners();

    try {
      final session = await _repository.restoreSession();
      _state = _state.copyWith(
        status: session == null
            ? AuthFlowStatus.unauthenticated
            : AuthFlowStatus.authenticated,
        session: session,
        clearError: true,
        clearSession: session == null,
      );
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        status: AuthFlowStatus.failure,
        errorMessage: error.toString(),
        clearSession: true,
      );
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberSession,
  }) async {
    _state = _state.copyWith(
      status: AuthFlowStatus.authenticating,
      rememberSession: rememberSession,
      clearError: true,
    );
    notifyListeners();

    try {
      final session = await _repository.login(email: email, password: password);
      _state = _state.copyWith(
        status: AuthFlowStatus.authenticated,
        session: session,
        rememberSession: rememberSession,
        clearError: true,
      );
      notifyListeners();
      return true;
    } catch (error) {
      _state = _state.copyWith(
        status: AuthFlowStatus.failure,
        errorMessage: _normalizeError(error),
        clearSession: true,
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _state = _state.copyWith(
      status: AuthFlowStatus.authenticating,
      clearError: true,
    );
    notifyListeners();

    try {
      await _repository.logout();
    } finally {
      _state = _state.copyWith(
        status: AuthFlowStatus.unauthenticated,
        clearSession: true,
        clearError: true,
      );
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    await _repository.forgotPassword(email);
  }

  void clearError() {
    if (_state.errorMessage == null) {
      return;
    }

    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }

  String _normalizeError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return message;
  }
}
