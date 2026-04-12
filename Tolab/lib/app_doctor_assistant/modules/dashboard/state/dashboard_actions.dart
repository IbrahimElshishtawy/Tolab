import '../../../core/models/dashboard_models.dart';

class LoadDashboardAction {
  const LoadDashboardAction({this.force = false});

  final bool force;
}

class LoadDashboardSuccessAction {
  LoadDashboardSuccessAction(this.data);

  final DashboardSnapshot data;
}

class LoadDashboardFailureAction {
  LoadDashboardFailureAction(this.message);

  final String message;
}
