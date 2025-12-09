import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/Api_Service_auth.dart';
import 'package:redux/redux.dart';
import '../app_state.dart';

import 'dashboard_actions.dart';

List<Middleware<AppState>> dashboardMiddleware(ApiService api) {
  return [
    TypedMiddleware<AppState, LoadDashboardDataAction>(
      _loadDashboard(api),
    ).call,
  ];
}

Middleware<AppState> _loadDashboard(ApiService api) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    try {
      final stats = await api.fetchDashboardStats();

      store.dispatch(
        DashboardDataLoadedAction(
          students: stats.totalStudents,
          doctors: stats.totalDoctors,
          subjects: stats.totalSubjects,
          pending: stats.pendingRequests,
          activity: stats.recentActivity,
        ),
      );
    } catch (e) {
      store.dispatch(DashboardDataFailedAction(e.toString()));
    }
  };
}
