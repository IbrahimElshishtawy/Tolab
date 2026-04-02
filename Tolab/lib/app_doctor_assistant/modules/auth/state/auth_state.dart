import '../../../core/state/async_state.dart';

class AuthState {
  const AuthState({
    this.status = ViewStatus.initial,
    this.error,
  });

  final ViewStatus status;
  final String? error;

  AuthState copyWith({
    ViewStatus? status,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
    );
  }
}
