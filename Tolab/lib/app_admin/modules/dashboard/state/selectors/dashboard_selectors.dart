import '../../../../state/app_state.dart';
import '../models/dashboard_state_models.dart';

DashboardState dashboardStateOf(AppState state) => state.dashboardState;

DashboardBundle? selectDashboardBundle(AppState state) =>
    state.dashboardState.bundle;

DashboardFilters selectDashboardFilters(AppState state) =>
    state.dashboardState.filters;

DashboardSearchScope selectDashboardSearchScope(AppState state) =>
    state.dashboardState.searchScope;

List<DashboardDirectoryEntry> selectDashboardSearchResults(AppState state) =>
    state.dashboardState.searchResults;

bool selectDashboardIsEmpty(AppState state) =>
    state.dashboardState.bundle?.isEmpty ?? true;
