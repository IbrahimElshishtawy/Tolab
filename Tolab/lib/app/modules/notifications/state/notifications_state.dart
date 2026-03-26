import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/notification_models.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef NotificationsState = EntityCollectionState<AdminNotification>;

const NotificationsState initialNotificationsState =
    EntityCollectionState<AdminNotification>();

class LoadNotificationsAction {}

class NotificationsLoadedAction {
  NotificationsLoadedAction(this.items);

  final List<AdminNotification> items;
}

class NotificationsFailedAction {
  NotificationsFailedAction(this.message);

  final String message;
}

NotificationsState notificationsReducer(
  NotificationsState state,
  dynamic action,
) {
  switch (action) {
    case LoadNotificationsAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case NotificationsLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case NotificationsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createNotificationsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadNotificationsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        store.dispatch(
          NotificationsLoadedAction(
            await deps.notificationsRepository.fetchNotifications(),
          ),
        );
      } catch (error) {
        store.dispatch(NotificationsFailedAction(error.toString()));
      }
    }).call,
  ];
}
