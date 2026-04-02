import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/staff_repository.dart';
import 'staff_actions.dart';

List<Middleware<DoctorAssistantAppState>> createStaffMiddleware(
  StaffRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadStaffAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final items = await repository.fetchStaff();
        store.dispatch(LoadStaffSuccessAction(items));
      } catch (error) {
        store.dispatch(LoadStaffFailureAction(error.toString()));
      }
    }).call,
  ];
}
