import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/auth/auth_state.dart';

class AppState {
  final AuthState auth;

  AppState({required this.auth});

  factory AppState.initial() {
    return AppState(auth: AuthState.initial());
  }

  AppState copyWith({AuthState? auth}) {
    return AppState(auth: auth ?? this.auth);
  }
}
