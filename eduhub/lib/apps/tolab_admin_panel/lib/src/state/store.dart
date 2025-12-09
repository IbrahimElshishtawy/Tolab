import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/Api_Service_auth.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/Api_Service_dashhoard.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/dashboard/dashboard_middleware.dart';
import 'package:redux/redux.dart';
import 'app_state.dart';
import 'reducers/app_reducer.dart';
import 'auth/auth_middleware.dart';

Store<AppState> createStore() {
  final apiAuth = ApiServiceAuth();
  final apiDashhoard = ApiServiceDashhoard();
  return Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [
      ...authMiddleware(apiAuth),
      ...dashboardMiddleware(apiDashhoard),
    ],
  );
}
