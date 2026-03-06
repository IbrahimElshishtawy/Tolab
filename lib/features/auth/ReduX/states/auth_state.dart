class AuthState {
  final bool isLoading;
  final String? uid;
  final String? email;
  final String? role;
  final bool isAuthenticated;
  final String? error;

  AuthState({
    required this.isLoading,
    this.uid,
    this.email,
    this.role,
    required this.isAuthenticated,
    this.error,
  });

  factory AuthState.initial() =>
      AuthState(isLoading: false, isAuthenticated: false, error: null);

  AuthState copyWith({
    bool? isLoading,
    String? uid,
    String? email,
    String? role,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
    );
  }
}
