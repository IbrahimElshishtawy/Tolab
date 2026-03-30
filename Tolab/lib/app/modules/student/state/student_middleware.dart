import 'package:redux/redux.dart';

import '../../academy_panel/models/academy_models.dart';
import '../../academy_panel/state/academy_actions.dart';
import '../../academy_panel/state/academy_state.dart';
import '../repositories/student_repository.dart';
import 'student_actions.dart';

List<Middleware<AcademyAppState>> createStudentMiddleware(
  StudentRepository repository,
) {
  return [
    TypedMiddleware<AcademyAppState, StudentLoadPageAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final page = await repository.fetchPage(
          action.pageKey,
          notifications: store.state.studentState.notifications,
        );
        store.dispatch(StudentPageLoadedAction(action.pageKey, page));
      } catch (error) {
        store.dispatch(StudentPageFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AcademyAppState, StudentCrudRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final message = await repository.saveRecord(
          action.pageKey,
          action.payload,
          entityId: action.entityId,
        );
        store.dispatch(
          AcademyToastQueuedAction(
            AcademyToast(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              title: 'Student Workspace',
              message: message,
              role: AcademyRole.student,
            ),
          ),
        );
        store.dispatch(StudentLoadPageAction(action.pageKey, force: true));
      } catch (error) {
        store.dispatch(StudentPageFailedAction(error.toString()));
      }
    }).call,
  ];
}
