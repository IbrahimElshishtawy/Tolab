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
        failureType: DashboardFailureType.none,
      );
    case LoadDashboardSuccessAction:
      return DashboardState(
        status: ViewStatus.success,
        data: (action as LoadDashboardSuccessAction).data,
        failureType: DashboardFailureType.none,
      );
    case LoadDashboardFailureAction:
      final failureAction = action as LoadDashboardFailureAction;
      return DashboardState(
        status: ViewStatus.failure,
        error: failureAction.message,
        failureType: failureAction.failureType,
      );
    default:
      return state;
  }
}
