import '../../../academy_panel/models/academy_models.dart';
import 'student_actions.dart';
import 'student_state.dart';

StudentState studentReducer(StudentState state, dynamic action) {
  switch (action) {
    case StudentNavigateAction():
      return state.copyWith(currentPageKey: action.pageKey);
    case StudentLoadPageAction():
      return state.copyWith(
        currentPageKey: action.pageKey,
        status: PanelLoadStatus.loading,
        clearError: true,
      );
    case StudentPageLoadedAction():
      return state.copyWith(
        status: PanelLoadStatus.success,
        pages: {...state.pages, action.pageKey: action.page},
        clearError: true,
      );
    case StudentPageFailedAction():
      return state.copyWith(
        status: PanelLoadStatus.failure,
        errorMessage: action.message,
      );
    case StudentNotificationReceivedAction():
      return state.copyWith(
        notifications: [action.notification, ...state.notifications],
      );
    case StudentNotificationReadAction():
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
