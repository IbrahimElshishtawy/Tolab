import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/Api_Service_auth.dart';
import 'package:redux/redux.dart';
import 'auth_actions.dart';

import '../app_state.dart';

List<Middleware<AppState>> authMiddleware(ApiService api) {
  return [TypedMiddleware<AppState, LoginAction>(_login(api)).call];
}

Middleware<AppState> _login(ApiService api) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    try {
      final token = await api.login(action.email, action.password);

      store.dispatch(LoginSuccessAction(token));
    } catch (e) {
      store.dispatch(LoginFailedAction(e.toString()));
    }
  };
}
