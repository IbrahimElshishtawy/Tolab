import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/subjects_repository.dart';
import 'subjects_actions.dart';

List<Middleware<DoctorAssistantAppState>> createSubjectsMiddleware(
  SubjectsRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadSubjectsAction>(
      (store, action, next) async {
        next(action);
        try {
          final items = await repository.fetchSubjects();
          store.dispatch(LoadSubjectsSuccessAction(items));
        } catch (error) {
          store.dispatch(LoadSubjectsFailureAction(error.toString()));
        }
      },
    ),
    TypedMiddleware<DoctorAssistantAppState, LoadSubjectDetailAction>(
      (store, action, next) async {
        next(action);
        final detailAction = action as LoadSubjectDetailAction;
        final subject = await repository.fetchSubjectDetail(detailAction.subjectId);
        store.dispatch(LoadSubjectDetailSuccessAction(subject));
      },
    ),
  ];
}
