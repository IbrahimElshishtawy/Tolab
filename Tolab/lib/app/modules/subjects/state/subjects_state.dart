import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/academic_models.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef SubjectsState = EntityCollectionState<SubjectModel>;

const SubjectsState initialSubjectsState =
    EntityCollectionState<SubjectModel>();

class LoadSubjectsAction {}

class SubjectsLoadedAction {
  SubjectsLoadedAction(this.items);

  final List<SubjectModel> items;
}

class SubjectsFailedAction {
  SubjectsFailedAction(this.message);

  final String message;
}

SubjectsState subjectsReducer(SubjectsState state, dynamic action) {
  switch (action) {
    case LoadSubjectsAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case SubjectsLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case SubjectsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createSubjectsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadSubjectsAction>((store, action, next) async {
      next(action);
      try {
        store.dispatch(
          SubjectsLoadedAction(await deps.subjectsRepository.fetchSubjects()),
        );
      } catch (error) {
        store.dispatch(SubjectsFailedAction(error.toString()));
      }
    }).call,
  ];
}
