import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/student.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef StudentsState = EntityCollectionState<Student>;

const StudentsState initialStudentsState = EntityCollectionState<Student>();

class LoadStudentsAction {}

class StudentsLoadedAction {
  StudentsLoadedAction(this.items);

  final List<Student> items;
}

class StudentsFailedAction {
  StudentsFailedAction(this.message);

  final String message;
}

StudentsState studentsReducer(StudentsState state, dynamic action) {
  switch (action) {
    case LoadStudentsAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case StudentsLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case StudentsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createStudentsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadStudentsAction>((store, action, next) async {
      next(action);
      try {
        store.dispatch(
          StudentsLoadedAction(await deps.studentsRepository.fetchStudents()),
        );
      } catch (error) {
        store.dispatch(StudentsFailedAction(error.toString()));
      }
    }).call,
  ];
}
