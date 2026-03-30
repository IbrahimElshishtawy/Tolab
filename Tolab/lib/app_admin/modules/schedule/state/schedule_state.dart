import '../../../shared/enums/load_status.dart';
import '../models/schedule_models.dart';

class ScheduleState {
  const ScheduleState({
    this.status = LoadStatus.initial,
    this.mutationStatus = LoadStatus.initial,
    this.events = const <ScheduleEventItem>[],
    this.lookups = const ScheduleLookupBundle(),
    this.filters = const ScheduleFilters(),
    this.view = ScheduleCalendarView.month,
    this.focusedDay,
    this.selectedDay,
    this.errorMessage,
    this.feedbackMessage,
    this.highlightedEventId,
  });

  final LoadStatus status;
  final LoadStatus mutationStatus;
  final List<ScheduleEventItem> events;
  final ScheduleLookupBundle lookups;
  final ScheduleFilters filters;
  final ScheduleCalendarView view;
  final DateTime? focusedDay;
  final DateTime? selectedDay;
  final String? errorMessage;
  final String? feedbackMessage;
  final String? highlightedEventId;

  ScheduleState copyWith({
    LoadStatus? status,
    LoadStatus? mutationStatus,
    List<ScheduleEventItem>? events,
    ScheduleLookupBundle? lookups,
    ScheduleFilters? filters,
    ScheduleCalendarView? view,
    DateTime? focusedDay,
    DateTime? selectedDay,
    String? errorMessage,
    String? feedbackMessage,
    String? highlightedEventId,
    bool clearError = false,
    bool clearFeedback = false,
    bool clearHighlight = false,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      events: events ?? this.events,
      lookups: lookups ?? this.lookups,
      filters: filters ?? this.filters,
      view: view ?? this.view,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      highlightedEventId: clearHighlight
          ? null
          : (highlightedEventId ?? this.highlightedEventId),
    );
  }
}

const ScheduleState initialScheduleState = ScheduleState();
