import '../../../core/state/async_state.dart';
import 'staff_actions.dart';
import 'staff_state.dart';

StaffState staffReducer(StaffState state, dynamic action) {
  switch (action.runtimeType) {
    case LoadStaffAction:
      return const StaffState(status: ViewStatus.loading);
    case LoadStaffSuccessAction:
      return StaffState(
        status: ViewStatus.success,
        data: (action as LoadStaffSuccessAction).items,
      );
    case LoadStaffFailureAction:
      return StaffState(
        status: ViewStatus.failure,
        error: (action as LoadStaffFailureAction).message,
      );
    default:
      return state;
  }
}
