// ignore_for_file: file_names

import '../app_state.dart';

bool canViewStudentsSelector(AppState state) =>
    state.permissions.canViewStudents;

bool canEditStudentsSelector(AppState state) =>
    state.permissions.canEditStudents;

bool canDeleteStudentsSelector(AppState state) =>
    state.permissions.canDeleteStudents;

bool canViewDoctorsSelector(AppState state) => state.permissions.canViewDoctors;

bool canEditDoctorsSelector(AppState state) => state.permissions.canEditDoctors;
