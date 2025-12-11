// ignore_for_file: file_names

import '../app_state.dart';

List<dynamic> selectDepartments(AppState state) =>
    state.academicStructure.departments;

List<dynamic> selectPrograms(AppState state) =>
    state.academicStructure.programs;

List<dynamic> selectYears(AppState state) => state.academicStructure.years;

bool selectAcademicLoading(AppState state) => state.academicStructure.isLoading;
