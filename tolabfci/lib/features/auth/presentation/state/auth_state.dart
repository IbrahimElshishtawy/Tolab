import '../../../../core/session/app_session.dart';

enum AuthStage { unauthenticated, awaitingNationalId, authenticated }

class AuthState {
  const AuthState({
    required this.stage,
    required this.role,
    this.isSubmitting = false,
    this.errorMessage,
  });

  const AuthState.initial()
    : this(stage: AuthStage.unauthenticated, role: AppUserRole.student);

  final AuthStage stage;
  final AppUserRole role;
  final bool isSubmitting;
  final String? errorMessage;

  AuthState copyWith({
    AuthStage? stage,
    AppUserRole? role,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      stage: stage ?? this.stage,
      role: role ?? this.role,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
