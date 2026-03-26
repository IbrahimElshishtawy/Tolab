import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/dashboard_models.dart';
import '../../../state/app_state.dart';

class DashboardState {
  const DashboardState({
    this.status = LoadStatus.initial,
    this.bundle,
    this.errorMessage,
  });

  final LoadStatus status;
  final DashboardBundle? bundle;
  final String? errorMessage;

  DashboardState copyWith({
    LoadStatus? status,
    DashboardBundle? bundle,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      bundle: bundle ?? this.bundle,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LoadDashboardAction {}

class DashboardLoadedAction {
  DashboardLoadedAction(this.bundle);

  final DashboardBundle bundle;
}

class DashboardFailedAction {
  DashboardFailedAction(this.message);

  final String message;
}

DashboardState dashboardReducer(DashboardState state, dynamic action) {
  switch (action) {
    case LoadDashboardAction():
      return state.copyWith(status: LoadStatus.loading, errorMessage: null);
    case DashboardLoadedAction():
      return state.copyWith(status: LoadStatus.success, bundle: action.bundle);
    case DashboardFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createDashboardMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadDashboardAction>((store, action, next) async {
      next(action);
      try {
        final bundle = await deps.dashboardRepository.fetchDashboard();
        store.dispatch(DashboardLoadedAction(bundle));
      } catch (error) {
        store.dispatch(DashboardFailedAction(error.toString()));
      }
    }).call,
  ];
}
