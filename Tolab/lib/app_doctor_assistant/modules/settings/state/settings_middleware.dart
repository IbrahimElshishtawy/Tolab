import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../../auth/state/session_actions.dart';
import '../repositories/settings_repository.dart';
import 'settings_actions.dart';

List<Middleware<DoctorAssistantAppState>> createSettingsMiddleware(
  SettingsRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, UpdateSettingsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final user = await repository.updateSettings(action.payload);
        store.dispatch(SessionEstablishedAction(user));
      } catch (error) {
        store.dispatch(UpdateSettingsFailureAction(error.toString()));
      }
    }).call,
  ];
}
