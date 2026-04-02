import '../../../core/state/async_state.dart';
import 'schedule_actions.dart';
import 'schedule_state.dart';

ScheduleState scheduleReducer(ScheduleState state, dynamic action) {
  switch (action.runtimeType) {
    case LoadScheduleAction _:
      return const ScheduleState(status: ViewStatus.loading);
    case LoadScheduleSuccessAction _:
      return ScheduleState(
        status: ViewStatus.success,
        data: (action as LoadScheduleSuccessAction).items,
      );
    case LoadScheduleFailureAction _:
      return ScheduleState(
        status: ViewStatus.failure,
        error: (action as LoadScheduleFailureAction).message,
      );
    default:
      return state;
  }
}
