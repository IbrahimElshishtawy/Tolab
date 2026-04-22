import '../../../core/models/dashboard_models.dart';
import 'dashboard_state.dart';

class LoadDashboardAction {
  const LoadDashboardAction({this.force = false});

  final bool force;
}

class LoadDashboardSuccessAction {
  LoadDashboardSuccessAction(this.data);

  final DashboardSnapshot data;
}

class LoadDashboardFailureAction {
  const LoadDashboardFailureAction(
    this.message, {
    this.failureType = DashboardFailureType.general,
  });

  const LoadDashboardFailureAction.authentication([
    this.message = 'Session expired, please login again.',
  ]) : failureType = DashboardFailureType.authentication;

  const LoadDashboardFailureAction.network([
    this.message =
        'We could not reach the dashboard. Check your connection and try again.',
  ]) : failureType = DashboardFailureType.network;

  final String message;
  final DashboardFailureType failureType;
}
