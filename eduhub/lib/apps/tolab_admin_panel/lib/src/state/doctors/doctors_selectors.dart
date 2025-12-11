import '../app_state.dart';

List<Map<String, dynamic>> doctorsSelector(AppState state) =>
    state.doctors.doctors;
bool doctorsLoadingSelector(AppState state) => state.doctors.isLoading;
String? doctorsErrorSelector(AppState state) => state.doctors.error;
