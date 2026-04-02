import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/lectures_repository.dart';
import 'lectures_actions.dart';

List<Middleware<DoctorAssistantAppState>> createLecturesMiddleware(
  LecturesRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadLecturesAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final items = await repository.fetchLectures();
        store.dispatch(LoadLecturesSuccessAction(items));
      } catch (error) {
        store.dispatch(LoadLecturesFailureAction(error.toString()));
      }
    }).call,
    TypedMiddleware<DoctorAssistantAppState, SaveLectureAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await repository.saveLecture((action).payload);
      store.dispatch(LoadLecturesAction());
    }).call,
    TypedMiddleware<DoctorAssistantAppState, DeleteLectureAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await repository.deleteLecture((action).lectureId);
      store.dispatch(LoadLecturesAction());
    }).call,
  ];
}
