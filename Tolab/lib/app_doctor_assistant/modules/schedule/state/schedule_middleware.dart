import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/schedule_repository.dart';
import 'schedule_actions.dart';

List<Middleware<DoctorAssistantAppState>> createScheduleMiddleware(
  ScheduleRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadScheduleAction>(
      (store, action, next) async {
        next(action);
        try {
          final items = await repository.fetchEvents();
          store.dispatch(LoadScheduleSuccessAction(items));
        } catch (error) {
          store.dispatch(LoadScheduleFailureAction(error.toString()));
        }
      },
    ),
  ];
}
