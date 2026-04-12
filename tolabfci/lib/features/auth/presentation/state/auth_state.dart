enum AuthStage { unauthenticated, awaitingNationalId, authenticated }

class AuthState {
  const AuthState({
    required this.stage,
    this.isSubmitting = false,
    this.errorMessage,
  });

  const AuthState.initial() : this(stage: AuthStage.unauthenticated);

  final AuthStage stage;
  final bool isSubmitting;
  final String? errorMessage;

  AuthState copyWith({
    AuthStage? stage,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      stage: stage ?? this.stage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
