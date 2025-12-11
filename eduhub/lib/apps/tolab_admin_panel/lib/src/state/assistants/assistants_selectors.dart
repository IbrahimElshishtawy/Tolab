import '../app_state.dart';

List<Map<String, dynamic>> assistantsSelector(AppState state) =>
    state.assistants.assistants;
bool assistantsLoadingSelector(AppState state) => state.assistants.isLoading;
String? assistantsErrorSelector(AppState state) => state.assistants.error;
