import '../app_state.dart';

studentsSelector(AppState state) => state.students.students;
studentsIsLoadingSelector(AppState state) => state.students.isLoading;
studentsErrorSelector(AppState state) => state.students.error;
