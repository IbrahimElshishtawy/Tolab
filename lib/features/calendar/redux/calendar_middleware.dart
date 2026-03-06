import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../../../mock/fake_repositories/calendar_fake_repo.dart';
import '../data/calendar_api.dart';
import '../../../config/env.dart';
import 'calendar_actions.dart';

List<Middleware<AppState>> createCalendarMiddlewares() {
  return [TypedMiddleware<AppState, FetchEventsAction>(_fetchEvents).call];
}

void _fetchEvents(
  Store<AppState> store,
  FetchEventsAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    List<dynamic> events;
    if (Env.useMock) {
      final repo = CalendarFakeRepo();
      events = await repo.getEvents();
    } else {
      final api = CalendarApi();
      final response = await api.getEvents();
      events = response.data;
    }
    store.dispatch(FetchEventsSuccessAction(events));
  } catch (e) {
    // handle error
  }
}
