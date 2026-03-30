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
      final effectiveQuery = state.searchQuery.trim();
      return state.copyWith(
        status: LoadStatus.success,
        refreshStatus: LoadStatus.success,
        bundle: action.bundle,
        filters: action.bundle.filters,
        searchResults: effectiveQuery.isEmpty
            ? action.bundle.directoryPreview
            : action.bundle.searchDirectory(
                query: effectiveQuery,
                scope: state.searchScope,
              ),
        searchStatus: LoadStatus.success,
        clearError: true,
        clearSearchError: true,
      );
    case DashboardFailedAction():
      return state.copyWith(
        status: state.bundle == null || !action.silent
            ? LoadStatus.failure
            : state.status,
        refreshStatus: action.silent ? LoadStatus.failure : state.refreshStatus,
        errorMessage: action.message,
      );
    case DashboardTimeRangeChangedAction():
      return state.copyWith(
        filters: state.filters.copyWith(timeRange: action.range),
        clearError: true,
      );
    case DashboardSearchQueryChangedAction():
      return state.copyWith(
        searchQuery: action.query,
        searchStatus: action.query.trim().isEmpty
            ? LoadStatus.success
            : LoadStatus.loading,
        searchResults: _localSearchResults(
          bundle: state.bundle,
          query: action.query,
          scope: state.searchScope,
        ),
        clearSearchError: true,
      );
    case DashboardSearchScopeChangedAction():
      return state.copyWith(
        searchScope: action.scope,
        searchStatus: state.searchQuery.trim().isEmpty
            ? LoadStatus.success
            : LoadStatus.loading,
        searchResults: _localSearchResults(
          bundle: state.bundle,
          query: state.searchQuery,
          scope: action.scope,
        ),
        clearSearchError: true,
      );
    case DashboardDirectorySearchRequestedAction():
      return state.copyWith(
        searchStatus: action.query.trim().isEmpty
            ? LoadStatus.success
            : LoadStatus.loading,
        clearSearchError: true,
      );
    case DashboardDirectorySearchLoadedAction():
      if (action.query.trim() != state.searchQuery.trim() ||
          action.scope != state.searchScope) {
        return state;
      }
      return state.copyWith(
        searchStatus: LoadStatus.success,
        searchResults: action.results,
        clearSearchError: true,
      );
    case DashboardDirectorySearchFailedAction():
      return state.copyWith(
        searchStatus: LoadStatus.failure,
        searchErrorMessage: action.message,
      );
    case DashboardRealtimeSignalReceivedAction():
      return state.copyWith(lastRealtimeSignalAt: action.signal.receivedAt);
    case DashboardFeedbackShownAction():
      return state.copyWith(feedbackMessage: action.message);
    case DashboardFeedbackDismissedAction():
      return state.copyWith(clearFeedback: true);
    default:
      return state;
  }
}

List<DashboardDirectoryEntry> _localSearchResults({
  required DashboardBundle? bundle,
  required String query,
  required DashboardSearchScope scope,
}) {
  if (bundle == null) {
    return const <DashboardDirectoryEntry>[];
  }
  if (query.trim().isEmpty) {
    return bundle.directoryPreview;
  }
  return bundle.searchDirectory(query: query, scope: scope);
}
