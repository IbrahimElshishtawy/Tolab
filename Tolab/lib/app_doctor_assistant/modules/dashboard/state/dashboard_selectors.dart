import '../../../core/state/async_state.dart';
import 'dashboard_state.dart';
import '../../../state/app_state.dart';

DashboardState getDashboardState(DoctorAssistantAppState state) =>
    state.dashboardState;

bool getDashboardIsLoading(DoctorAssistantAppState state) =>
    getDashboardState(state).status == ViewStatus.loading;

bool getDashboardHasData(DoctorAssistantAppState state) =>
    getDashboardState(state).data != null;

String? getDashboardError(DoctorAssistantAppState state) =>
    getDashboardState(state).error;
