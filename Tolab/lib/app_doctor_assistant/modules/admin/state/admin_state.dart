import '../../../core/models/academic_models.dart';
import '../../../core/state/async_state.dart';

class AdminState {
  const AdminState({
    this.overview = const AsyncState<Map<String, dynamic>>(),
    this.permissions = const AsyncState<List<String>>(),
    this.departments = const AsyncState<List<DepartmentModel>>(),
  });

  final AsyncState<Map<String, dynamic>> overview;
  final AsyncState<List<String>> permissions;
  final AsyncState<List<DepartmentModel>> departments;

  AdminState copyWith({
    AsyncState<Map<String, dynamic>>? overview,
    AsyncState<List<String>>? permissions,
    AsyncState<List<DepartmentModel>>? departments,
  }) {
    return AdminState(
      overview: overview ?? this.overview,
      permissions: permissions ?? this.permissions,
      departments: departments ?? this.departments,
    );
  }
}
