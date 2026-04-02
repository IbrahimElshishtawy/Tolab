import '../../../core/state/async_state.dart';
import '../../auth/state/session_actions.dart';
import 'settings_actions.dart';
import 'settings_state.dart';

SettingsState settingsReducer(SettingsState state, dynamic action) {
  switch (action.runtimeType) {
    case UpdateSettingsAction _:
      return SettingsState(status: ViewStatus.loading, data: state.data);
    case SessionEstablishedAction _:
      return SettingsState(
        status: ViewStatus.success,
        data: (action as SessionEstablishedAction).user,
      );
    case UpdateSettingsFailureAction _:
      return SettingsState(
        status: ViewStatus.failure,
        error: (action as UpdateSettingsFailureAction).message,
        data: state.data,
      );
    default:
      return state;
  }
}
