import '../../../core/models/academic_models.dart';
import '../../../core/state/async_state.dart';
import 'admin_actions.dart';
import 'admin_state.dart';

AdminState adminReducer(AdminState state, dynamic action) {
  switch (action) {
    case LoadAdminOverviewAction _:
      return state.copyWith(
        overview: const AsyncState<Map<String, dynamic>>(
          status: ViewStatus.loading,
        ),
      );
    case LoadAdminOverviewSuccessAction action:
      return state.copyWith(
        overview: AsyncState<Map<String, dynamic>>(
          status: ViewStatus.success,
          data: action.data,
        ),
      );
    case LoadPermissionsAction _:
      return state.copyWith(
        permissions: const AsyncState<List<String>>(status: ViewStatus.loading),
      );
    case LoadPermissionsSuccessAction action:
      return state.copyWith(
        permissions: AsyncState<List<String>>(
          status: ViewStatus.success,
          data: action.items,
        ),
      );
    case LoadDepartmentsAction _:
      return state.copyWith(
        departments: const AsyncState<List<DepartmentModel>>(
          status: ViewStatus.loading,
        ),
      );
    case LoadDepartmentsSuccessAction action:
      return state.copyWith(
        departments: AsyncState<List<DepartmentModel>>(
          status: ViewStatus.success,
          data: action.items,
        ),
      );
    case AdminFailureAction action:
      return state.copyWith(
        overview: AsyncState<Map<String, dynamic>>(
          status: ViewStatus.failure,
          error: action.message,
          data: state.overview.data,
        ),
      );
    default:
      return state;
  }
}
