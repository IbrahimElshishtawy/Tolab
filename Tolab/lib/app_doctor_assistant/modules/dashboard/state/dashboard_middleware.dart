import 'package:redux/redux.dart';

import '../../../core/network/api_exception.dart';
import '../../../state/app_state.dart';
import '../repositories/dashboard_repository.dart';
import 'dashboard_actions.dart';

List<Middleware<DoctorAssistantAppState>> createDashboardMiddleware(
  DashboardRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadDashboardAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final data = await repository.fetchDashboard();
        store.dispatch(LoadDashboardSuccessAction(data));
      } on ApiException catch (error) {
        if (error.statusCode == 401) {
          store.dispatch(const LoadDashboardFailureAction.authentication());
          return;
        }

        if (_isNetworkFailure(error)) {
          store.dispatch(LoadDashboardFailureAction.network(error.message));
          return;
        }

        store.dispatch(LoadDashboardFailureAction(error.message));
      } catch (error) {
        store.dispatch(LoadDashboardFailureAction(error.toString()));
      }
    }).call,
  ];
}

bool _isNetworkFailure(ApiException error) {
  final message = error.message.toLowerCase();
  return error.statusCode == null &&
      (message.contains('connection') ||
          message.contains('timed out') ||
          message.contains('socket') ||
          message.contains('network'));
}
