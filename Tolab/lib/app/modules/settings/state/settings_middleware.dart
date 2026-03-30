import 'package:redux/redux.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_dependencies.dart';
import '../../../state/app_state.dart';
import '../../notifications/state/notifications_state.dart';
import 'settings_actions.dart';

List<Middleware<AppState>> createSettingsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadSettingsAction>((store, action, next) async {
      next(action);
      try {
        final bundle = await deps.settingsRepository.fetchSettings();
        store.dispatch(SettingsLoadedAction(bundle));
      } catch (error) {
        store.dispatch(SettingsLoadFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, SaveSettingsRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final result = await deps.settingsRepository.saveSettings(
          store.state.settingsState.bundle,
        );
        store.dispatch(SettingsSaveSucceededAction(result));
        if (result.notification != null) {
          store.dispatch(
            IncomingNotificationAction(
              result.notification!,
              showLocalAlert: false,
              showToast:
                  store.state.settingsState.bundle.notifications.toastEnabled,
            ),
          );
        }
      } catch (error) {
        store.dispatch(SettingsSaveFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, CreateSettingsBackupRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final result = await deps.settingsRepository.createBackup(
          store.state.settingsState.bundle,
        );
        store.dispatch(SettingsSaveSucceededAction(result));
        if (result.notification != null) {
          store.dispatch(
            IncomingNotificationAction(
              result.notification!,
              showLocalAlert: false,
              showToast:
                  store.state.settingsState.bundle.notifications.toastEnabled,
            ),
          );
        }
      } catch (error) {
        store.dispatch(SettingsSaveFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, RestoreSettingsBackupRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final result = await deps.settingsRepository.restoreBackup(
          currentBundle: store.state.settingsState.bundle,
          backupId: action.backupId,
        );
        store.dispatch(SettingsSaveSucceededAction(result));
        if (result.notification != null) {
          store.dispatch(
            IncomingNotificationAction(
              result.notification!,
              showLocalAlert: false,
              showToast:
                  store.state.settingsState.bundle.notifications.toastEnabled,
            ),
          );
        }
      } catch (error) {
        store.dispatch(SettingsSaveFailedAction(_messageOf(error)));
      }
    }).call,
  ];
}

String _messageOf(Object error) {
  if (error is AppException) return error.message;
  return error.toString();
}
