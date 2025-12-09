import 'package:redux/redux.dart';
import '../../core/api/Api_Service_dashhoard.dart';
import '../app_state.dart';
import 'dashboard_actions.dart';

List<Middleware<AppState>> dashboardMiddleware(ApiServiceDashhoard api) {
  return [
    TypedMiddleware<AppState, LoadDashboardDataAction>(
      _loadDashboard(api),
    ).call,
  ];
}

Middleware<AppState> _loadDashboard(ApiServiceDashhoard api) {
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
