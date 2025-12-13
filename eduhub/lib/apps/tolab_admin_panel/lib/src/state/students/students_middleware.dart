// students_middleware.dart

import 'package:redux/redux.dart';
import 'students_actions.dart';
import '../app_state.dart';

List<Middleware<AppState>> students() {
  return [
    TypedMiddleware<AppState, FilterStudentsByYearAction>(
      _filterStudentsByYear,
    ).call,
    TypedMiddleware<AppState, FilterStudentsByDepartmentAction>(
      _filterStudentsByDepartment,
    ).call,
  ];
}

void _filterStudentsByYear(
  Store<AppState> store,
  FilterStudentsByYearAction action,
  NextDispatcher next,
) async => next(action);

void _filterStudentsByDepartment(
  Store<AppState> store,
  FilterStudentsByDepartmentAction action,
  NextDispatcher next,
) async {
  next(action);
}
