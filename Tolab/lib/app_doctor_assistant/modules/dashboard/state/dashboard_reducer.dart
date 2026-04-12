// ignore_for_file: type_literal_in_constant_pattern

import '../../../core/state/async_state.dart';
import 'dashboard_actions.dart';
import 'dashboard_state.dart';

DashboardState dashboardReducer(DashboardState state, dynamic action) {
  switch (action.runtimeType) {
    case LoadDashboardAction:
      return DashboardState(
        status: ViewStatus.loading,
        data: state.data,
        error: state.error,
      );
    case LoadDashboardSuccessAction:
      return DashboardState(
        status: ViewStatus.success,
        data: (action as LoadDashboardSuccessAction).data,
      );
    case LoadDashboardFailureAction:
      return DashboardState(
        status: ViewStatus.failure,
        error: (action as LoadDashboardFailureAction).message,
      );
    default:
      return state;
  }
}
