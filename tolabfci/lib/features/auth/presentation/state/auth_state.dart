import '../../../../core/session/app_session.dart';

enum AuthStage {
  unauthenticated,
  awaitingNationalId,
  awaitingOtp,
  awaitingNewPassword,
  authenticated,
}

class AuthState {
  const AuthState({
    required this.stage,
    required this.role,
    this.nationalId,
    this.isSubmitting = false,
    this.errorMessage,
  });

  const AuthState.initial()
    : this(stage: AuthStage.unauthenticated, role: AppUserRole.student);

  final AuthStage stage;
  final AppUserRole role;
  final String? nationalId;
  final bool isSubmitting;
  final String? errorMessage;

  AuthState copyWith({
    AuthStage? stage,
    AppUserRole? role,
    String? nationalId,
    bool? isSubmitting,
    String? errorMessage,
    bool clearNationalId = false,
    bool clearError = false,
  }) {
    return AuthState(
      stage: stage ?? this.stage,
      role: role ?? this.role,
      nationalId: clearNationalId ? null : nationalId ?? this.nationalId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
