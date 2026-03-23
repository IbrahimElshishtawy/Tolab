class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? email;
  final String? role; // 'ADMIN' or 'STUDENT'
  final String? error;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.email,
    this.role,
    this.error,
  });

  factory AuthState.initial() => AuthState(
        isAuthenticated: false,
        isLoading: false,
      );

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? email,
    String? role,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      email: email ?? this.email,
      role: role ?? this.role,
      error: error ?? this.error,
    );
  }
}
