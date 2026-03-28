import 'package:dio/dio.dart';
import 'package:redux/redux.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/app_dependencies.dart';
import '../../../../state/app_state.dart';
import '../actions/dashboard_actions.dart';

List<Middleware<AppState>> createDashboardMiddleware(AppDependencies deps) {
  CancelToken? activeToken;

  return [
    TypedMiddleware<AppState, LoadDashboardRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      activeToken?.cancel('Superseded dashboard request');
      final token = CancelToken();
      activeToken = token;

      try {
        final bundle = await deps.dashboardRepository.fetchDashboard(
          filters: store.state.dashboardState.filters,
          cancelToken: token,
        );
        if (token.isCancelled || activeToken != token) {
          return;
        }
        store.dispatch(DashboardLoadedAction(bundle));
      } on DioException catch (error) {
        if (error.type == DioExceptionType.cancel) {
          return;
        }
        store.dispatch(
          DashboardFailedAction(_messageOf(error), silent: action.silent),
        );
      } catch (error) {
        store.dispatch(
          DashboardFailedAction(_messageOf(error), silent: action.silent),
        );
      } finally {
        if (identical(activeToken, token)) {
          activeToken = null;
        }
      }
    }).call,
    TypedMiddleware<AppState, DashboardFilterChangedAction>((
      store,
      action,
      next,
    ) {
      next(action);
      store.dispatch(const LoadDashboardRequestedAction(silent: true));
    }).call,
    TypedMiddleware<AppState, DashboardFiltersResetAction>((
      store,
      action,
      next,
    ) {
      next(action);
      store.dispatch(const LoadDashboardRequestedAction(silent: true));
    }).call,
  ];
}

String _messageOf(Object error) {
  if (error is AppException) {
    return error.message;
  }
  if (error is DioException && error.type == DioExceptionType.cancel) {
    return 'The request was cancelled.';
  }
  return error.toString();
}
