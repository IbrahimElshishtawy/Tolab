// ignore_for_file: unnecessary_cast

import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/subjects_repository.dart';
import 'subjects_actions.dart';

List<Middleware<DoctorAssistantAppState>> createSubjectsMiddleware(
  SubjectsRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadSubjectsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final items = await repository.fetchSubjects();
        store.dispatch(LoadSubjectsSuccessAction(items));
      } catch (error) {
        store.dispatch(LoadSubjectsFailureAction(error.toString()));
      }
    }).call,
    TypedMiddleware<DoctorAssistantAppState, LoadSubjectWorkspaceAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      final detailAction = action as LoadSubjectWorkspaceAction;
      try {
        final workspace = await repository.fetchSubjectWorkspace(
          detailAction.subjectId,
        );
        store.dispatch(LoadSubjectWorkspaceSuccessAction(workspace));
      } catch (error) {
        store.dispatch(LoadSubjectWorkspaceFailureAction(error.toString()));
      }
    }).call,
  ];
}
