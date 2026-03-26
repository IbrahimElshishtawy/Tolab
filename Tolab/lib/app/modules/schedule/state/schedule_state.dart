import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/schedule_models.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef ScheduleState = EntityCollectionState<ScheduleEventModel>;

const ScheduleState initialScheduleState =
    EntityCollectionState<ScheduleEventModel>();

class LoadScheduleAction {}

class ScheduleLoadedAction {
  ScheduleLoadedAction(this.items);

  final List<ScheduleEventModel> items;
}

class ScheduleFailedAction {
  ScheduleFailedAction(this.message);

  final String message;
}

ScheduleState scheduleReducer(ScheduleState state, dynamic action) {
  switch (action) {
    case LoadScheduleAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case ScheduleLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case ScheduleFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createScheduleMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadScheduleAction>((store, action, next) async {
      next(action);
      try {
        store.dispatch(
          ScheduleLoadedAction(await deps.scheduleRepository.fetchSchedule()),
        );
      } catch (error) {
        store.dispatch(ScheduleFailedAction(error.toString()));
      }
    }).call,
  ];
}
