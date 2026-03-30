import '../../academy_panel/models/academy_models.dart';
import 'doctor_actions.dart';
import 'doctor_state.dart';

DoctorState doctorReducer(DoctorState state, dynamic action) {
  switch (action) {
    case DoctorNavigateAction():
      return state.copyWith(currentPageKey: action.pageKey);
    case DoctorLoadPageAction():
      return state.copyWith(
        currentPageKey: action.pageKey,
        status: PanelLoadStatus.loading,
        clearError: true,
      );
    case DoctorPageLoadedAction():
      return state.copyWith(
        status: PanelLoadStatus.success,
        pages: {...state.pages, action.pageKey: action.page},
        clearError: true,
      );
    case DoctorPageFailedAction():
      return state.copyWith(
        status: PanelLoadStatus.failure,
        errorMessage: action.message,
      );
    case DoctorNotificationReceivedAction():
      return state.copyWith(
        notifications: [action.notification, ...state.notifications],
      );
    case DoctorNotificationReadAction():
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
