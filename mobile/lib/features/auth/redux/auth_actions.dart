import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import '../data/auth_repository.dart';
import '../../../redux/app_state.dart';

class LoginStartAction {}

class LoginSuccessAction {
  final String email;
  final String role;
  LoginSuccessAction(this.email, this.role);
}

class LoginFailureAction {
  final String error;
  LoginFailureAction(this.error);
}

class LogoutAction {}

ThunkAction<AppState> loginAction(String email, String password) {
  return (Store<AppState> store) async {
    store.dispatch(LoginStartAction());
    try {
      final repo = AuthRepository();
      final response = await repo.login(email, password);
      store.dispatch(LoginSuccessAction(email, response.role));
    } catch (e) {
      store.dispatch(LoginFailureAction(e.toString()));
    }
  };
}
