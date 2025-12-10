import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/Api_Service_dashhoard.dart';
import 'package:redux/redux.dart';
import '../app_state.dart';
import 'dashboard_actions.dart';

List<Middleware<AppState>> dashboardMiddleware(ApiServiceDashboard api) {
  return [
    TypedMiddleware<AppState, LoadDashboardDataAction>(
      _loadDashboard(api),
    ).call,
  ];
}

Middleware<AppState> _loadDashboard(ApiServiceDashboard api) {
  return (store, action, next) async {
    next(action);

    final data = await api.fetchDashboardState();

    store.dispatch(
      DashboardDataLoadedAction(
        students: data.totalStudents,
        doctors: data.totalDoctors,
        subjects: data.totalSubjects,
        pending: data.pendingRequests,
        activity: data.recentActivity,
      ),
    );
  };
}
