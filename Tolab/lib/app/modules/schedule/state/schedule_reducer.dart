import '../../../shared/enums/load_status.dart';
import 'schedule_actions.dart';
import 'schedule_state.dart';

ScheduleState scheduleReducer(ScheduleState state, dynamic action) {
  switch (action) {
    case FetchScheduleAction():
      return state.copyWith(
        status: action.silent ? LoadStatus.refreshing : LoadStatus.loading,
        clearError: true,
      );
    case ScheduleLoadedAction():
      final firstEventDay = action.bundle.events.isEmpty
          ? null
          : _stripTime(action.bundle.events.first.startAt);
      return state.copyWith(
        status: LoadStatus.success,
        events: action.bundle.events,
        lookups: action.bundle.lookups,
        focusedDay: state.focusedDay ?? firstEventDay ?? DateTime.now(),
        selectedDay: state.selectedDay ?? firstEventDay ?? DateTime.now(),
        clearError: true,
      );
    case ScheduleFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    case ScheduleViewChangedAction():
      return state.copyWith(view: action.view);
    case ScheduleFocusedDayChangedAction():
      return state.copyWith(focusedDay: _stripTime(action.day));
    case ScheduleSelectedDayChangedAction():
      final normalized = _stripTime(action.day);
      return state.copyWith(focusedDay: normalized, selectedDay: normalized);
    case ScheduleFiltersChangedAction():
      return state.copyWith(filters: action.filters);
    case ScheduleEventHighlightedAction():
      return state.copyWith(highlightedEventId: action.eventId);
    case ScheduleMutationStartedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.loading,
        clearFeedback: true,
        clearError: true,
      );
    case ScheduleMutationSucceededAction():
      return state.copyWith(
        mutationStatus: LoadStatus.success,
        status: LoadStatus.success,
        events: action.result.events,
        lookups: action.result.lookups,
        feedbackMessage: action.result.message,
        highlightedEventId: action.result.highlightedEventId,
        clearError: true,
      );
    case ScheduleMutationFailedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.failure,
        feedbackMessage: action.message,
      );
    case ClearScheduleFeedbackAction():
      return state.copyWith(
        mutationStatus: LoadStatus.initial,
        clearFeedback: true,
        clearHighlight: true,
      );
    default:
      return state;
  }
}

DateTime _stripTime(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
