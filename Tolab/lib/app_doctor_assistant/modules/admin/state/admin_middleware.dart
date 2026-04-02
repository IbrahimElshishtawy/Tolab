import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/admin_repository.dart';
import '../../staff/state/staff_actions.dart';
import 'admin_actions.dart';

List<Middleware<DoctorAssistantAppState>> createAdminMiddleware(
  AdminRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadAdminOverviewAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final data = await repository.fetchOverview();
        store.dispatch(LoadAdminOverviewSuccessAction(data));
      } catch (error) {
        store.dispatch(AdminFailureAction(error.toString()));
      }
    }).call,
    TypedMiddleware<DoctorAssistantAppState, LoadPermissionsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final items = await repository.fetchPermissions();
        store.dispatch(LoadPermissionsSuccessAction(items));
      } catch (error) {
        store.dispatch(AdminFailureAction(error.toString()));
      }
    }).call,
    TypedMiddleware<DoctorAssistantAppState, LoadDepartmentsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final items = await repository.fetchDepartments();
        store.dispatch(LoadDepartmentsSuccessAction(items));
      } catch (error) {
        store.dispatch(AdminFailureAction(error.toString()));
      }
    }).call,
    TypedMiddleware<DoctorAssistantAppState, ToggleStaffActivationAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await repository.toggleActivation(
        action.userId,
        action.isActive,
      );
      store.dispatch(LoadStaffAction());
    }).call,
  ];
}
