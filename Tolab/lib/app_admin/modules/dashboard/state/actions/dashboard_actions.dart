import '../models/dashboard_state_models.dart';

class LoadDashboardRequestedAction {
  const LoadDashboardRequestedAction({this.silent = false});

  final bool silent;
}

class DashboardLoadedAction {
  const DashboardLoadedAction(this.bundle);

  final DashboardBundle bundle;
}

class DashboardFailedAction {
  const DashboardFailedAction(this.message, {this.silent = false});

  final String message;
  final bool silent;
}

enum DashboardFilterField { semester, department, course, instructor }

class DashboardFilterChangedAction {
  const DashboardFilterChangedAction({
    required this.field,
    required this.value,
  });

  final DashboardFilterField field;
  final String? value;
}

class DashboardFiltersResetAction {
  const DashboardFiltersResetAction();
}

class DashboardFeedbackShownAction {
  const DashboardFeedbackShownAction(this.message);

  final String message;
}

class DashboardFeedbackDismissedAction {
  const DashboardFeedbackDismissedAction();
}
