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

class StartDashboardRealtimeAction {
  const StartDashboardRealtimeAction();
}

class StopDashboardRealtimeAction {
  const StopDashboardRealtimeAction();
}

class DashboardRealtimeSignalReceivedAction {
  const DashboardRealtimeSignalReceivedAction(this.signal);

  final DashboardRealtimeSignal signal;
}

class DashboardTimeRangeChangedAction {
  const DashboardTimeRangeChangedAction(this.range);

  final DashboardTimeRange range;
}

class DashboardSearchQueryChangedAction {
  const DashboardSearchQueryChangedAction(this.query);

  final String query;
}

class DashboardSearchScopeChangedAction {
  const DashboardSearchScopeChangedAction(this.scope);

  final DashboardSearchScope scope;
}

class DashboardDirectorySearchRequestedAction {
  const DashboardDirectorySearchRequestedAction({
    required this.query,
    required this.scope,
  });

  final String query;
  final DashboardSearchScope scope;
}

class DashboardDirectorySearchLoadedAction {
  const DashboardDirectorySearchLoadedAction({
    required this.query,
    required this.scope,
    required this.results,
  });

  final String query;
  final DashboardSearchScope scope;
  final List<DashboardDirectoryEntry> results;
}

class DashboardDirectorySearchFailedAction {
  const DashboardDirectorySearchFailedAction(this.message);

  final String message;
}

class DashboardFeedbackShownAction {
  const DashboardFeedbackShownAction(this.message);

  final String message;
}

class DashboardFeedbackDismissedAction {
  const DashboardFeedbackDismissedAction();
}
