import 'auth_state.dart';

class AppState {
  final AuthState authState;

  AppState({required this.authState});
  factory AppState.initial() {
    return AppState(authState: AuthState.initial());
  }

  AppState copyWith({AuthState? authState}) {
    return AppState(authState: authState ?? this.authState);
  }
}
