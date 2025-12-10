import 'package:redux/redux.dart';
import '../../core/api/Api_Service_dashhoard.dart';
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
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    try {
      final stats = await api.fetchDashboardState();

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
