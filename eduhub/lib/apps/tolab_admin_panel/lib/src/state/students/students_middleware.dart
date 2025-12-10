import 'package:eduhub/fake_data/data.dart';
import 'package:redux/redux.dart';

import '../app_state.dart';
import 'students_actions.dart';

List<Middleware<AppState>> studentsMiddleware() {
  return [TypedMiddleware<AppState, LoadStudentsAction>(_loadStudents()).call];
}

Middleware<AppState> _loadStudents() {
  return (store, action, next) async {
    next(action);

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      store.dispatch(StudentsLoadedAction(students));
    } catch (e) {
      store.dispatch(StudentsFailedAction(e.toString()));
    }
  };
}
