class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? token;
  final String? error;

  AuthState({
    required this.isLoading,
    required this.isLoggedIn,
    this.token,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(
      isLoading: false,
      isLoggedIn: false,
      token: null,
      error: null,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? token,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      error: error,
    );
  }
}
