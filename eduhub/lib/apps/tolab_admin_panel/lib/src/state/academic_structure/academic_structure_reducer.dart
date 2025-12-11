// ignore_for_file: file_names

import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/academic_structure/structure_state.dart';
import 'package:redux/redux.dart';
import 'academic_structure_actions.dart';

final academicStructureReducer = combineReducers<AcademicStructureState>([
  TypedReducer<AcademicStructureState, AcademicStructureLoadedAction>(
    _onLoaded,
  ).call,
  TypedReducer<AcademicStructureState, AcademicStructureFailedAction>(
    _onFailed,
  ).call,
]);

AcademicStructureState _onLoaded(
  AcademicStructureState state,
  AcademicStructureLoadedAction action,
) {
  return state.copyWith(
    isLoading: false,
    departments: action.departments,
    programs: action.programs,
    years: action.years,
    error: null,
  );
}

AcademicStructureState _onFailed(
  AcademicStructureState state,
  AcademicStructureFailedAction action,
) {
  return state.copyWith(isLoading: false, error: action.error);
}
