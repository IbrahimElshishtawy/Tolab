import '../app_state.dart';

List<Map<String, dynamic>> studentsSelector(AppState state) =>
    state.students.students;
bool studentsIsLoadingSelector(AppState state) => state.students.isLoading;
String? studentsErrorSelector(AppState state) => state.students.error;
