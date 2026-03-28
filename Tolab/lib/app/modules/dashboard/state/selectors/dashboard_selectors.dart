import '../../../../state/app_state.dart';
import '../models/dashboard_state_models.dart';

DashboardState dashboardStateOf(AppState state) => state.dashboardState;

DashboardBundle? selectDashboardBundle(AppState state) =>
    state.dashboardState.bundle;

DashboardFilters selectDashboardFilters(AppState state) =>
    state.dashboardState.filters;

DashboardLookups selectDashboardLookups(AppState state) =>
    state.dashboardState.bundle?.lookups ?? const DashboardLookups();

bool selectDashboardIsEmpty(AppState state) =>
    state.dashboardState.bundle?.isEmpty ?? false;
