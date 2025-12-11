import 'package:redux/redux.dart';
import '../../core/api/api_service_students.dart';
import '../app_state.dart';
import 'students_actions.dart';

List<Middleware<AppState>> createStudentsMiddleware(ApiServiceStudents api) {
  return [TypedMiddleware<AppState, LoadStudentsAction>(_loadStudents(api))];
}

Middleware<AppState> _loadStudents(ApiServiceStudents api) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    try {
      final data = await api.fetchStudents();
      store.dispatch(StudentsLoadedAction(data));
    } catch (e) {
      store.dispatch(StudentsFailedAction(e.toString()));
    }
  };
}
