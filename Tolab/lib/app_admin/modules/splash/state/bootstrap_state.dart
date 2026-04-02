import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../auth/state/auth_state.dart';
import '../../settings/state/settings_actions.dart';
import '../../../state/app_state.dart';

class BootstrapState {
  const BootstrapState({
    this.status = LoadStatus.initial,
    this.isReady = false,
    this.errorMessage,
  });

  final LoadStatus status;
  final bool isReady;
  final String? errorMessage;

  BootstrapState copyWith({
    LoadStatus? status,
    bool? isReady,
    String? errorMessage,
  }) {
    return BootstrapState(
      status: status ?? this.status,
      isReady: isReady ?? this.isReady,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BootstrapRequestedAction {}

class BootstrapCompletedAction {}

class BootstrapFailedAction {
  BootstrapFailedAction(this.message);

  final String message;
}

BootstrapState bootstrapReducer(BootstrapState state, dynamic action) {
  switch (action) {
    case BootstrapRequestedAction():
      return state.copyWith(status: LoadStatus.loading, errorMessage: null);
    case BootstrapCompletedAction():
      return state.copyWith(status: LoadStatus.success, isReady: true);
    case BootstrapFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
        isReady: true,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createBootstrapMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, BootstrapRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final hasUsableSession = await deps.authService.hasUsableSession();
        final settings = await deps.settingsRepository.fetchSettings(
          preferRemote: hasUsableSession,
        );
        store.dispatch(SettingsLoadedAction(settings));

        final hasSession = await deps.authService.hasSession();
        if (hasSession) {
          final user = await deps.authService.isDemoSession()
              ? deps.demoDataService.adminProfile()
              : await deps.authRepository.me();
          store.dispatch(HydrateUserAction(user));
        }

        store.dispatch(BootstrapCompletedAction());
      } catch (error) {
        store.dispatch(BootstrapFailedAction(error.toString()));
      }
    }).call,
  ];
}
