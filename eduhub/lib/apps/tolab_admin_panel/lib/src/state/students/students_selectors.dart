import '../app_state.dart';
import 'students_state.dart';

StudentsState studentsSelector(AppState state) => state.students;

List<Map<String, dynamic>> allStudentsSelector(AppState state) =>
    state.students.students;

bool studentsLoadingSelector(AppState state) => state.students.isLoading;

String? studentsErrorSelector(AppState state) => state.students.error;
