import 'dart:convert';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolab_fci/features/auth/ReduX/action/auth_actions.dart';
import 'package:tolab_fci/redux/state/app_state.dart';
import 'package:tolab_fci/core/network/api_client.dart';
import 'package:tolab_fci/core/network/endpoints.dart';

List<Middleware<AppState>> createAuthMiddleware(dynamic repository) {
  return [authMiddleware];
}

void authMiddleware(
  Store<AppState> store,
  dynamic action,
  NextDispatcher next,
) async {
  if (action is LoginAction) {
    store.dispatch(LoginLoadingAction());
    final apiClient = ApiClient();

    try {
      final response = await apiClient.postForm(Endpoints.login, {
        'username': action.email,
        'password': action.password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final role = data['role'];

        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setString('user_role', role);

        store.dispatch(LoginSuccessAction(action.email, action.email, role, token: token));
      } else {
        final errorData = jsonDecode(response.body);
        store.dispatch(LoginFailureAction(errorData['detail'] ?? 'Login failed'));
      }
    } catch (e) {
      store.dispatch(LoginFailureAction(e.toString()));
    }
    return;
  }

  if (action is LogoutAction) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_role');
  }

  next(action);
}
