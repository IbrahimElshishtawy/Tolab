class AuthState {
  final bool isLoading;
  final String? uid;
  final String? email;
  final String? role;

  AuthState({
    required this.isLoading,
    this.uid,
    this.email,
    this.role,
    required bool isAuthenticated,
    required error,
  });

  factory AuthState.initial() =>
      AuthState(isLoading: false, isAuthenticated: false, error: null);
}
