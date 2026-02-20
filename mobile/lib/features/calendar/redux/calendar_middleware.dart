import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../../../mock/fake_repositories/calendar_fake_repo.dart';
import 'calendar_actions.dart';

List<Middleware<AppState>> createCalendarMiddlewares() {
  return [
    TypedMiddleware<AppState, FetchEventsAction>(_fetchEvents),
  ];
}

void _fetchEvents(Store<AppState> store, FetchEventsAction action, NextDispatcher next) async {
  next(action);
  try {
    final repo = CalendarFakeRepo();
    final events = await repo.getEvents();
    store.dispatch(FetchEventsSuccessAction(events));
  } catch (e) {
    // handle error
  }
}
