import '../../../../shared/enums/load_status.dart';
import '../../models/dashboard_models.dart';

export '../../models/dashboard_models.dart';

class DashboardState {
  const DashboardState({
    this.status = LoadStatus.initial,
    this.refreshStatus = LoadStatus.initial,
    this.bundle,
    this.filters = const DashboardFilters(),
    this.errorMessage,
    this.feedbackMessage,
  });

  final LoadStatus status;
  final LoadStatus refreshStatus;
  final DashboardBundle? bundle;
  final DashboardFilters filters;
  final String? errorMessage;
  final String? feedbackMessage;

  DashboardState copyWith({
    LoadStatus? status,
    LoadStatus? refreshStatus,
    DashboardBundle? bundle,
    DashboardFilters? filters,
    String? errorMessage,
    String? feedbackMessage,
    bool clearBundle = false,
    bool clearError = false,
    bool clearFeedback = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      refreshStatus: refreshStatus ?? this.refreshStatus,
      bundle: clearBundle ? null : bundle ?? this.bundle,
      filters: filters ?? this.filters,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      feedbackMessage: clearFeedback
          ? null
          : feedbackMessage ?? this.feedbackMessage,
    );
  }
}
