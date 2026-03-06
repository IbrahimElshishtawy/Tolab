import 'calendar_state.dart';
import 'calendar_actions.dart';

CalendarState calendarReducer(CalendarState state, dynamic action) {
  if (action is FetchEventsAction) {
    return state.copyWith(isLoading: true);
  }
  if (action is FetchEventsSuccessAction) {
    return state.copyWith(isLoading: false, events: action.events);
  }
  return state;
}
