import 'package:redux/redux.dart';
import '../app_state.dart';
import '../../core/api/Api_Service_auth.dart';
import 'auth_actions.dart';

import '../permissions/permissions_actions.dart';
import '../dashboard/dashboard_actions.dart';

List<Middleware<AppState>> authMiddleware(ApiServiceAuth api) {
  return [TypedMiddleware<AppState, LoginAction>(_login(api)).call];
}

Middleware<AppState> _login(ApiServiceAuth api) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    try {
      final token = await api.login(action.email, action.password);

      store.dispatch(LoginSuccessAction(token: token, email: action.email));

      store.dispatch(LoadPermissionsAction());
      store.dispatch(LoadDashboardDataAction());
    } catch (e) {
      store.dispatch(LoginFailedAction(e.toString()));
    }
  };
}
