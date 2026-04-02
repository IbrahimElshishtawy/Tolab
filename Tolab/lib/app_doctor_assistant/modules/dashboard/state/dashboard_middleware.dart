import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/dashboard_repository.dart';
import 'dashboard_actions.dart';

List<Middleware<DoctorAssistantAppState>> createDashboardMiddleware(
  DashboardRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadDashboardAction>(
      (store, action, next) async {
        next(action);
        try {
          final data = await repository.fetchDashboard();
          store.dispatch(LoadDashboardSuccessAction(data));
        } catch (error) {
          store.dispatch(LoadDashboardFailureAction(error.toString()));
        }
      },
    ),
  ];
}
