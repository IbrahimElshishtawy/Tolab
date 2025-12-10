import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/app_state.dart';
import 'package:redux/redux.dart';

import 'students_actions.dart';

// استيراد الفيك داتا
import 'package:eduhub/fake_data/data.dart';

List<Middleware<AppState>> studentsMiddleware() {
  return [TypedMiddleware<AppState, LoadStudentsAction>(_loadStudents()).call];
}

Middleware<AppState> _loadStudents() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      store.dispatch(StudentsLoadedAction(students));
    } catch (e) {
      store.dispatch(StudentsFailedAction(e.toString()));
    }
  };
}
