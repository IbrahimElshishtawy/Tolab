import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/auth_state.dart';

class AppState {
  final AuthState authState;
  AppState({required this.authState});

  factory AppState.initial() {
    return AppState(authState: AuthState.initial());
    // Add other initial states here as needed
  }
  AppState copyWith({AuthState? authState}) {
    return AppState(authState: authState ?? this.authState);
    // Add other states here as needed
  }
}
