import '../../../core/models/dashboard_models.dart';

class LoadDashboardAction {}

class LoadDashboardSuccessAction {
  LoadDashboardSuccessAction(this.data);

  final DashboardSnapshot data;
}

class LoadDashboardFailureAction {
  LoadDashboardFailureAction(this.message);

  final String message;
}
