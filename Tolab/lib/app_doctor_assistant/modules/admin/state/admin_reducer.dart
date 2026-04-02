import '../../../core/state/async_state.dart';
import 'admin_actions.dart';
import 'admin_state.dart';

AdminState adminReducer(AdminState state, dynamic action) {
  switch (action.runtimeType) {
    case LoadAdminOverviewAction:
      return state.copyWith(
        overview: const AsyncState<Map<String, dynamic>>(
          status: ViewStatus.loading,
        ),
      );
    case LoadAdminOverviewSuccessAction:
      return state.copyWith(
        overview: AsyncState<Map<String, dynamic>>(
          status: ViewStatus.success,
          data: (action as LoadAdminOverviewSuccessAction).data,
        ),
      );
    case LoadPermissionsAction:
      return state.copyWith(
        permissions: const AsyncState<List<String>>(status: ViewStatus.loading),
      );
    case LoadPermissionsSuccessAction:
      return state.copyWith(
        permissions: AsyncState<List<String>>(
          status: ViewStatus.success,
          data: (action as LoadPermissionsSuccessAction).items,
        ),
      );
    case LoadDepartmentsAction:
      return state.copyWith(
        departments: const AsyncState<List<DepartmentModel>>(
          status: ViewStatus.loading,
        ),
      );
    case LoadDepartmentsSuccessAction:
      return state.copyWith(
        departments: AsyncState<List<DepartmentModel>>(
          status: ViewStatus.success,
          data: (action as LoadDepartmentsSuccessAction).items,
        ),
      );
    case AdminFailureAction:
      return state.copyWith(
        overview: AsyncState<Map<String, dynamic>>(
          status: ViewStatus.failure,
          error: (action as AdminFailureAction).message,
          data: state.overview.data,
        ),
      );
    default:
      return state;
  }
}
