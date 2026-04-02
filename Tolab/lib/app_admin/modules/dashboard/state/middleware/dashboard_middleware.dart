import 'dart:async';

import 'package:dio/dio.dart';
import 'package:redux/redux.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/app_dependencies.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../state/app_state.dart';
import '../../../auth/state/auth_state.dart';
import '../actions/dashboard_actions.dart';
import '../models/dashboard_state_models.dart';

List<Middleware<AppState>> createDashboardMiddleware(AppDependencies deps) {
  CancelToken? activeDashboardToken;
  CancelToken? activeSearchToken;
  Timer? searchDebounce;
  StreamSubscription<DashboardRealtimeSignal>? realtimeSubscription;

  Future<void> stopRealtime() async {
    await realtimeSubscription?.cancel();
    realtimeSubscription = null;
  }

  return [
    TypedMiddleware<AppState, LoadDashboardRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      activeDashboardToken?.cancel('Superseded dashboard request');
      final token = CancelToken();
      activeDashboardToken = token;

      try {
        final preferRemote = await deps.authService.hasUsableSession();
        final bundle = await deps.dashboardRepository.fetchDashboard(
          filters: store.state.dashboardState.filters,
          cancelToken: token,
          preferRemote: preferRemote,
        );
        if (token.isCancelled || activeDashboardToken != token) {
          return;
        }
        store.dispatch(DashboardLoadedAction(bundle));
      } on DioException catch (error) {
        if (error.type == DioExceptionType.cancel) return;
        store.dispatch(
          DashboardFailedAction(_messageOf(error), silent: action.silent),
        );
      } catch (error) {
        store.dispatch(
          DashboardFailedAction(_messageOf(error), silent: action.silent),
        );
      } finally {
        if (identical(activeDashboardToken, token)) {
          activeDashboardToken = null;
        }
      }
    }).call,
    TypedMiddleware<AppState, DashboardTimeRangeChangedAction>((
      store,
      action,
      next,
    ) {
      next(action);
      store.dispatch(const LoadDashboardRequestedAction(silent: true));
    }).call,
    TypedMiddleware<AppState, DashboardSearchQueryChangedAction>((
      store,
      action,
      next,
    ) {
      next(action);
      searchDebounce?.cancel();
      final query = store.state.dashboardState.searchQuery.trim();
      if (query.isEmpty) {
        return;
      }
      searchDebounce = Timer(const Duration(milliseconds: 280), () {
        final state = store.state.dashboardState;
        store.dispatch(
          DashboardDirectorySearchRequestedAction(
            query: state.searchQuery,
            scope: state.searchScope,
          ),
        );
      });
    }).call,
    TypedMiddleware<AppState, DashboardSearchScopeChangedAction>((
      store,
      action,
      next,
    ) {
      next(action);
      searchDebounce?.cancel();
      final query = store.state.dashboardState.searchQuery.trim();
      if (query.isEmpty) {
        return;
      }
      searchDebounce = Timer(const Duration(milliseconds: 180), () {
        final state = store.state.dashboardState;
        store.dispatch(
          DashboardDirectorySearchRequestedAction(
            query: state.searchQuery,
            scope: state.searchScope,
          ),
        );
      });
    }).call,
    TypedMiddleware<AppState, DashboardDirectorySearchRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      activeSearchToken?.cancel('Superseded search request');
      if (action.query.trim().isEmpty) {
        return;
      }

      final token = CancelToken();
      activeSearchToken = token;
      try {
        final preferRemote = await deps.authService.hasUsableSession();
        final results = await deps.dashboardRepository.searchDirectory(
          query: action.query,
          scope: action.scope,
          cancelToken: token,
          preferRemote: preferRemote,
        );
        if (token.isCancelled || activeSearchToken != token) {
          return;
        }
        store.dispatch(
          DashboardDirectorySearchLoadedAction(
            query: action.query,
            scope: action.scope,
            results: results,
          ),
        );
      } on DioException catch (error) {
        if (error.type == DioExceptionType.cancel) return;
        store.dispatch(DashboardDirectorySearchFailedAction(_messageOf(error)));
      } catch (error) {
        store.dispatch(DashboardDirectorySearchFailedAction(_messageOf(error)));
      } finally {
        if (identical(activeSearchToken, token)) {
          activeSearchToken = null;
        }
      }
    }).call,
    TypedMiddleware<AppState, StartDashboardRealtimeAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await stopRealtime();

      if (!await deps.authService.hasUsableSession()) {
        return;
      }

      final accessToken = await deps.secureStorage.readAccessToken();
      final userId = store.state.authState.currentUser?.id;

      realtimeSubscription = deps.dashboardRepository
          .watchRealtimeSignals(accessToken: accessToken, userId: userId)
          .listen((signal) {
            store.dispatch(DashboardRealtimeSignalReceivedAction(signal));
            if (store.state.dashboardState.status != LoadStatus.loading) {
              store.dispatch(const LoadDashboardRequestedAction(silent: true));
            }
          });
    }).call,
    TypedMiddleware<AppState, StopDashboardRealtimeAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await stopRealtime();
    }).call,
    TypedMiddleware<AppState, LogoutCompletedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      searchDebounce?.cancel();
      await stopRealtime();
    }).call,
  ];
}

String _messageOf(Object error) {
  if (error is AppException) return error.message;
  if (error is DioException && error.type == DioExceptionType.cancel) {
    return 'The request was cancelled.';
  }
  return error.toString();
}
