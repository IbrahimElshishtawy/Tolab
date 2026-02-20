import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../../../config/env.dart';
import '../data/auth_repository.dart';
import '../../../mock/fake_repositories/auth_fake_repo.dart';
import 'auth_actions.dart';

List<Middleware<AppState>> createAuthMiddlewares() {
  return [
    TypedMiddleware<AppState, LoginAction>(_loginMiddleware),
  ];
}

void _loginMiddleware(Store<AppState> store, LoginAction action, NextDispatcher next) async {
  next(action); // Let the reducer handle LoginStartAction if needed, but here we dispatch explicit start action

  store.dispatch(LoginStartAction());

  try {
    String role;
    if (Env.useMock) {
      final repo = AuthFakeRepo();
      final response = await repo.login(action.email, action.password);
      role = response.role;
    } else {
      final repo = AuthRepository();
      final response = await repo.login(action.email, action.password);
      role = response.role;
    }
    store.dispatch(LoginSuccessAction(action.email, role));
  } catch (e) {
    store.dispatch(LoginFailureAction(e.toString()));
  }
}
