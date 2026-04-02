import '../models/auth_session.dart';
import '../models/auth_user.dart';

enum AuthFlowStatus {
  initial,
  bootstrapping,
  unauthenticated,
  authenticating,
  authenticated,
  failure,
}

class UnifiedAuthState {
  const UnifiedAuthState({
    this.status = AuthFlowStatus.initial,
    this.session,
    this.errorMessage,
    this.rememberSession = true,
  });

  final AuthFlowStatus status;
  final AuthSession? session;
  final String? errorMessage;
  final bool rememberSession;

  AuthUser? get user => session?.user;

  bool get isBootstrapping => status == AuthFlowStatus.bootstrapping;

  bool get isLoading =>
      status == AuthFlowStatus.bootstrapping ||
      status == AuthFlowStatus.authenticating;

  bool get isAuthenticated => session != null;

  bool get isInactive => user != null && !user!.isActive;

  UnifiedAuthState copyWith({
    AuthFlowStatus? status,
    AuthSession? session,
    String? errorMessage,
    bool? rememberSession,
    bool clearSession = false,
    bool clearError = false,
  }) {
    return UnifiedAuthState(
      status: status ?? this.status,
      session: clearSession ? null : session ?? this.session,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      rememberSession: rememberSession ?? this.rememberSession,
    );
  }
}
