class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? uid;
  final String? email;
  final String? role;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.uid,
    this.email,
    this.role,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
      uid: null,
      email: null,
      role: null,
      error: null,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? uid,
    String? email,
    String? role,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      error: error,
    );
  }
}
