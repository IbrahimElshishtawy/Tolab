import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/app_state.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/auth/auth_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(auth: authReducer(state.auth, action));
}
