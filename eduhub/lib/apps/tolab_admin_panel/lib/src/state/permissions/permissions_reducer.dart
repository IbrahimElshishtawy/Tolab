// ignore_for_file: file_names

import 'package:redux/redux.dart';
import 'permissions_actions.dart';
import 'permissions_state.dart';

final permissionsReducer = combineReducers<PermissionsState>([
  TypedReducer<PermissionsState, PermissionsLoadedAction>(_onLoaded).call,
  TypedReducer<PermissionsState, UpdatePermissionsAction>(_onUpdated).call,
  TypedReducer<PermissionsState, PermissionsFailedAction>(_onFailed).call,
]);

PermissionsState _onLoaded(
  PermissionsState state,
  PermissionsLoadedAction action,
) {
  return PermissionsState(
    canViewStudents:
        action.permissions["canViewStudents"] ?? state.canViewStudents,
    canEditStudents:
        action.permissions["canEditStudents"] ?? state.canEditStudents,
    canDeleteStudents:
        action.permissions["canDeleteStudents"] ?? state.canDeleteStudents,
    canViewDoctors:
        action.permissions["canViewDoctors"] ?? state.canViewDoctors,
    canEditDoctors:
        action.permissions["canEditDoctors"] ?? state.canEditDoctors,
  );
}

PermissionsState _onUpdated(
  PermissionsState state,
  UpdatePermissionsAction action,
) {
  return state.copyWith(
    canViewStudents: action.updates["canViewStudents"],
    canEditStudents: action.updates["canEditStudents"],
    canDeleteStudents: action.updates["canDeleteStudents"],
    canViewDoctors: action.updates["canViewDoctors"],
    canEditDoctors: action.updates["canEditDoctors"],
  );
}

PermissionsState _onFailed(
  PermissionsState state,
  PermissionsFailedAction action,
) {
  return state; // لا شيء يتغير – فقط Log
}
