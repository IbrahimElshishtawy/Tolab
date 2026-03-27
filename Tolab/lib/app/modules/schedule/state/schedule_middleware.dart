import 'package:redux/redux.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_dependencies.dart';
import '../../../state/app_state.dart';
import 'schedule_actions.dart';

List<Middleware<AppState>> createScheduleMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, FetchScheduleAction>((store, action, next) async {
      next(action);
      try {
        final bundle = await deps.scheduleRepository.fetchSchedule(
          filters: store.state.scheduleState.filters,
        );
        store.dispatch(ScheduleLoadedAction(bundle));
      } catch (error) {
        store.dispatch(ScheduleFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, ScheduleFiltersChangedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const FetchScheduleAction(silent: true));
    }).call,
    TypedMiddleware<AppState, CreateScheduleEventAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const ScheduleMutationStartedAction());
      try {
        final result = await deps.scheduleRepository.createEvent(
          action.payload,
        );
        store.dispatch(ScheduleMutationSucceededAction(result));
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(ScheduleMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
    TypedMiddleware<AppState, UpdateScheduleEventAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const ScheduleMutationStartedAction());
      try {
        final result = await deps.scheduleRepository.updateEvent(
          eventId: action.eventId,
          payload: action.payload,
        );
        store.dispatch(ScheduleMutationSucceededAction(result));
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(ScheduleMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
    TypedMiddleware<AppState, DeleteScheduleEventAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const ScheduleMutationStartedAction());
      try {
        final result = await deps.scheduleRepository.deleteEvent(
          eventId: action.eventId,
        );
        store.dispatch(ScheduleMutationSucceededAction(result));
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(ScheduleMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
    TypedMiddleware<AppState, RescheduleScheduleEventAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const ScheduleMutationStartedAction());
      try {
        final result = await deps.scheduleRepository.rescheduleEvent(
          event: action.event,
          targetStart: action.targetStart,
          targetEnd: action.targetEnd,
        );
        store.dispatch(ScheduleMutationSucceededAction(result));
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(ScheduleMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
  ];
}

String _messageOf(Object error) {
  if (error is AppException) return error.message;
  return error.toString();
}
