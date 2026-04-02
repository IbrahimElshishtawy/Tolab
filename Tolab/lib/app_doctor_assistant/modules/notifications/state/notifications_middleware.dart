import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/notifications_repository.dart';
import 'notifications_actions.dart';

List<Middleware<DoctorAssistantAppState>> createNotificationsMiddleware(
  NotificationsRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadNotificationsAction>(
      (store, action, next) async {
        next(action);
        try {
          final items = await repository.fetchNotifications();
          store.dispatch(LoadNotificationsSuccessAction(items));
        } catch (error) {
          store.dispatch(LoadNotificationsFailureAction(error.toString()));
        }
      },
    ),
    TypedMiddleware<DoctorAssistantAppState, MarkNotificationReadAction>(
      (store, action, next) async {
        next(action);
        await repository.markRead((action as MarkNotificationReadAction).notificationId);
        store.dispatch(LoadNotificationsAction());
      },
    ),
  ];
}
