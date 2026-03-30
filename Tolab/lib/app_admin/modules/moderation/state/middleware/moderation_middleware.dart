import 'dart:async';

import 'package:redux/redux.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/app_dependencies.dart';
import '../../../../state/app_state.dart';
import '../actions/moderation_actions.dart';

List<Middleware<AppState>> createModerationMiddleware(AppDependencies deps) {
  Timer? pollingTimer;

  return [
    TypedMiddleware<AppState, LoadModerationDashboardRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final bundle = await deps.moderationRepository.fetchDashboard();
        store.dispatch(ModerationDashboardLoadedAction(bundle));
      } catch (error) {
        store.dispatch(ModerationDashboardFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, PerformModerationActionRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const ModerationMutationStartedAction());
      try {
        final result = await deps.moderationRepository.performAction(
          action.command,
        );
        store.dispatch(ModerationMutationSucceededAction(result));
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(ModerationMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
    TypedMiddleware<AppState, StartModerationNotificationsPollingAction>((
      store,
      action,
      next,
    ) {
      next(action);
      pollingTimer ??= Timer.periodic(
        const Duration(seconds: 45),
        (_) => store.dispatch(const RefreshModerationNotificationsRequestedAction()),
      );
      store.dispatch(const RefreshModerationNotificationsRequestedAction());
    }).call,
    TypedMiddleware<AppState, StopModerationNotificationsPollingAction>((
      store,
      action,
      next,
    ) {
      next(action);
      pollingTimer?.cancel();
      pollingTimer = null;
    }).call,
    TypedMiddleware<AppState, RefreshModerationNotificationsRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final notifications = await deps.moderationRepository.fetchNotifications();
        store.dispatch(ModerationNotificationsLoadedAction(notifications));
      } catch (error) {
        store.dispatch(ModerationNotificationsFailedAction(_messageOf(error)));
      }
    }).call,
  ];
}

String _messageOf(Object error) {
  if (error is AppException) return error.message;
  return error.toString();
}
