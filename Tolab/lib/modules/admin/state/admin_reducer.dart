import '../../../academy_panel/models/academy_models.dart';
import 'admin_actions.dart';
import 'admin_state.dart';

AdminState adminReducer(AdminState state, dynamic action) {
  switch (action) {
    case AdminNavigateAction():
      return state.copyWith(currentPageKey: action.pageKey);
    case AdminLoadPageAction():
      return state.copyWith(
        currentPageKey: action.pageKey,
        status: PanelLoadStatus.loading,
        clearError: true,
      );
    case AdminPageLoadedAction():
      return state.copyWith(
        status: PanelLoadStatus.success,
        pages: {...state.pages, action.pageKey: action.page},
        clearError: true,
      );
    case AdminPageFailedAction():
      return state.copyWith(
        status: PanelLoadStatus.failure,
        errorMessage: action.message,
      );
    case AdminNotificationReceivedAction():
      return state.copyWith(
        notifications: [action.notification, ...state.notifications],
      );
    case AdminNotificationReadAction():
      return state.copyWith(
        notifications: state.notifications
            .map(
              (item) => item.id == action.notificationId
                  ? item.copyWith(isRead: true)
                  : item,
            )
            .toList(),
      );
    default:
      return state;
  }
}
