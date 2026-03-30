import '../../../../shared/enums/load_status.dart';
import '../../models/dashboard_models.dart';

export '../../models/dashboard_models.dart';

class DashboardState {
  const DashboardState({
    this.status = LoadStatus.initial,
    this.refreshStatus = LoadStatus.initial,
    this.searchStatus = LoadStatus.initial,
    this.bundle,
    this.filters = const DashboardFilters(),
    this.searchScope = DashboardSearchScope.all,
    this.searchQuery = '',
    this.searchResults = const <DashboardDirectoryEntry>[],
    this.errorMessage,
    this.searchErrorMessage,
    this.feedbackMessage,
    this.lastRealtimeSignalAt,
  });

  final LoadStatus status;
  final LoadStatus refreshStatus;
  final LoadStatus searchStatus;
  final DashboardBundle? bundle;
  final DashboardFilters filters;
  final DashboardSearchScope searchScope;
  final String searchQuery;
  final List<DashboardDirectoryEntry> searchResults;
  final String? errorMessage;
  final String? searchErrorMessage;
  final String? feedbackMessage;
  final DateTime? lastRealtimeSignalAt;

  DashboardState copyWith({
    LoadStatus? status,
    LoadStatus? refreshStatus,
    LoadStatus? searchStatus,
    DashboardBundle? bundle,
    DashboardFilters? filters,
    DashboardSearchScope? searchScope,
    String? searchQuery,
    List<DashboardDirectoryEntry>? searchResults,
    String? errorMessage,
    String? searchErrorMessage,
    String? feedbackMessage,
    DateTime? lastRealtimeSignalAt,
    bool clearBundle = false,
    bool clearError = false,
    bool clearSearchError = false,
    bool clearFeedback = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      refreshStatus: refreshStatus ?? this.refreshStatus,
      searchStatus: searchStatus ?? this.searchStatus,
      bundle: clearBundle ? null : bundle ?? this.bundle,
      filters: filters ?? this.filters,
      searchScope: searchScope ?? this.searchScope,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      searchErrorMessage: clearSearchError
          ? null
          : searchErrorMessage ?? this.searchErrorMessage,
      feedbackMessage: clearFeedback
          ? null
          : feedbackMessage ?? this.feedbackMessage,
      lastRealtimeSignalAt: lastRealtimeSignalAt ?? this.lastRealtimeSignalAt,
    );
  }
}
