import 'dashboard_actions.dart';
import 'dashboard_state.dart';

DashboardStats dashboardReducer(DashboardStats state, dynamic action) {
  if (action is LoadDashboardDataAction) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is DashboardDataLoadedAction) {
    return state.copyWith(
      isLoading: false,
      totalStudents: action.students,
      totalDoctors: action.doctors,
      totalSubjects: action.subjects,
      pendingRequests: action.pending,
      recentActivity: action.activity,
    );
  }

  if (action is DashboardDataFailedAction) {
    return state.copyWith(isLoading: false, error: action.message);
  }

  return state;
}
