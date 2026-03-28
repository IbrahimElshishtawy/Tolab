import '../../../../shared/enums/load_status.dart';
import '../actions/dashboard_actions.dart';
import '../models/dashboard_state_models.dart';

DashboardState dashboardReducer(DashboardState state, dynamic action) {
  switch (action) {
    case LoadDashboardRequestedAction():
      final isInitialLoad = !action.silent || state.bundle == null;
      return state.copyWith(
        status: isInitialLoad ? LoadStatus.loading : state.status,
        refreshStatus: isInitialLoad ? LoadStatus.initial : LoadStatus.loading,
        clearError: true,
      );
    case DashboardLoadedAction():
      return state.copyWith(
        status: LoadStatus.success,
        refreshStatus: LoadStatus.success,
        bundle: action.bundle,
        filters: action.bundle.filters,
        clearError: true,
      );
    case DashboardFailedAction():
      return state.copyWith(
        status: state.bundle == null || !action.silent
            ? LoadStatus.failure
            : state.status,
        refreshStatus: action.silent ? LoadStatus.failure : state.refreshStatus,
        errorMessage: action.message,
      );
    case DashboardFilterChangedAction():
      return state.copyWith(
        filters: switch (action.field) {
          DashboardFilterField.semester => state.filters.copyWith(
            semesterId: action.value,
          ),
          DashboardFilterField.department => state.filters.copyWith(
            departmentId: action.value,
            clearCourse: true,
            clearInstructor: true,
          ),
          DashboardFilterField.course => state.filters.copyWith(
            courseId: action.value,
          ),
          DashboardFilterField.instructor => state.filters.copyWith(
            instructorId: action.value,
          ),
        },
        clearError: true,
      );
    case DashboardFiltersResetAction():
      return state.copyWith(
        filters: const DashboardFilters(),
        clearError: true,
      );
    case DashboardFeedbackShownAction():
      return state.copyWith(feedbackMessage: action.message);
    case DashboardFeedbackDismissedAction():
      return state.copyWith(clearFeedback: true);
    default:
      return state;
  }
}
