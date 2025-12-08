class AuthState {
  final bool isloading;
  final bool isloadingIn;
  final String? errorMessage;
  final String? token;
  // Add other fields as needed
  //final User? user;
  // final bool isAuthenticated;
  // final bool isEmailVerified;
  // final bool isFirstTimeUser;
  // final List<String> roles;
  AuthState({
    required this.isloading,
    required this.isloadingIn,
    this.errorMessage,
    this.token,
    // Add other fields here as needed
    // this.user,
    // this.isAuthenticated = false,
    // this.isEmailVerified = false,
    // this.isFirstTimeUser = true,
    // this.roles = const [],
  });
  factory AuthState.initial() {
    return AuthState(
      isloading: false,
      isloadingIn: false,
      errorMessage: null,
      token: null,
      // Initialize other fields as needed
      // user: null,
      // isAuthenticated: false,
      // isEmailVerified: false,
      // isFirstTimeUser: true,
      // roles: [],
    );
  }
  AuthState copyWith({
    bool? isloading,
    bool? isloadingIn,
    String? errorMessage,
    String? token,
    // Add other fields here as needed
    // User? user,
    // bool? isAuthenticated,
    // bool? isEmailVerified,
    // bool? isFirstTimeUser,
    // List<String>? roles,
  }) {
    return AuthState(
      isloading: isloading ?? this.isloading,
      isloadingIn: isloadingIn ?? this.isloadingIn,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
      // Copy other fields as needed
      // user: user ?? this.user,
      // isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      // isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      // isFirstTimeUser: isFirstTimeUser ?? this.isFirstTimeUser,
      // roles: roles ?? this.roles,
    );
  }
}
