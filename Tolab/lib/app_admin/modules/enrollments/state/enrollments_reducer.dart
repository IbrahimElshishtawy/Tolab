import '../../../shared/enums/load_status.dart';
import 'enrollments_actions.dart';
import 'enrollments_state.dart';

EnrollmentsState enrollmentsReducer(EnrollmentsState state, dynamic action) {
  switch (action) {
    case FetchEnrollmentsAction():
      return state.copyWith(
        status: action.silent ? LoadStatus.refreshing : LoadStatus.loading,
        clearError: true,
      );
    case EnrollmentsLoadedAction():
      return state.copyWith(
        status: LoadStatus.success,
        items: action.bundle.items,
        pagination: action.bundle.pagination,
        lookups: action.bundle.lookups,
        summary: action.bundle.summary,
        clearError: true,
      );
    case EnrollmentsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    case EnrollmentsFiltersChangedAction():
      return state.copyWith(
        filters: action.filters,
        pagination: state.pagination.copyWith(page: 1),
      );
    case EnrollmentsSortChangedAction():
      return state.copyWith(
        sort: action.sort,
        pagination: state.pagination.copyWith(page: 1),
      );
    case EnrollmentsPaginationChangedAction():
      return state.copyWith(pagination: action.pagination);
    case EnrollmentSelectionToggledAction():
      final selected = <String>{...state.selectedIds};
      if (action.selected) {
        selected.add(action.enrollmentId);
      } else {
        selected.remove(action.enrollmentId);
      }
      return state.copyWith(selectedIds: selected);
    case EnrollmentSelectionClearedAction():
      return state.copyWith(selectedIds: const <String>{});
    case EnrollmentMutationStartedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.loading,
        clearFeedback: true,
        clearError: true,
      );
    case EnrollmentMutationSucceededAction():
      return state.copyWith(
        mutationStatus: LoadStatus.success,
        items: action.result.items,
        pagination: action.result.pagination,
        summary: action.result.summary,
        feedbackMessage: action.result.message,
        highlightedEnrollmentId: action.result.highlightEnrollmentId,
        clearError: true,
      );
    case EnrollmentMutationFailedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.failure,
        feedbackMessage: action.message,
      );
    case ResetEnrollmentFeedbackAction():
      return state.copyWith(
        mutationStatus: LoadStatus.initial,
        clearFeedback: true,
        clearHighlight: true,
      );
    case EnrollmentBulkPreviewPreparedAction():
      return state.copyWith(bulkPreview: action.preview);
    case ClearEnrollmentBulkPreviewAction():
      return state.copyWith(clearBulkPreview: true);
    default:
      return state;
  }
}
