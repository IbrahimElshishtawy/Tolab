import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/auth/auth_state.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/dashboard/dashboard_state.dart';

class AppState {
  final AuthState auth;
  final DashboardState dashboard;

  AppState({required this.auth, required this.dashboard});

  factory AppState.initial() {
    return AppState(
      auth: AuthState.initial(),
      dashboard: DashboardState.initial(),
    );
  }

  AppState copyWith({AuthState? auth, DashboardState? dashboard}) {
    return AppState(
      auth: auth ?? this.auth,
      dashboard: dashboard ?? this.dashboard,
    );
  }
}
