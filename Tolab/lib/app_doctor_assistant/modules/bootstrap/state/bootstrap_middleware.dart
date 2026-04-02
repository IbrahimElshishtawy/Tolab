// ignore_for_file: implicit_call_tearoffs

import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../../auth/state/session_actions.dart';
import '../../auth/repositories/auth_repository.dart';
import 'bootstrap_actions.dart';

List<Middleware<DoctorAssistantAppState>> createBootstrapMiddleware(
  AuthRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, BootstrapStartedAction>(
      _bootstrap(repository),
    ),
  ];
}

Middleware<DoctorAssistantAppState> _bootstrap(AuthRepository repository) {
  return (store, action, next) async {
    next(action);
    try {
      final restoredUser = await repository.restoreSession();
      if (restoredUser != null) {
        final currentUser = await repository.fetchCurrentUser();
        store.dispatch(SessionEstablishedAction(currentUser));
      } else {
        store.dispatch(const SessionClearedAction());
      }
      store.dispatch(BootstrapCompletedAction());
    } catch (error) {
      store.dispatch(const SessionClearedAction());
      store.dispatch(BootstrapFailedAction(error.toString()));
    }
  };
}
