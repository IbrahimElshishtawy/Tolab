import 'package:redux/redux.dart';

import '../../../academy_panel/models/academy_models.dart';
import '../../../academy_panel/state/academy_actions.dart';
import '../../../academy_panel/state/academy_state.dart';
import '../repositories/doctor_repository.dart';
import 'doctor_actions.dart';

List<Middleware<AcademyAppState>> createDoctorMiddleware(
  DoctorRepository repository,
) {
  return [
    TypedMiddleware<AcademyAppState, DoctorLoadPageAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final page = await repository.fetchPage(
          action.pageKey,
          notifications: store.state.doctorState.notifications,
        );
        store.dispatch(DoctorPageLoadedAction(action.pageKey, page));
      } catch (error) {
        store.dispatch(DoctorPageFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AcademyAppState, DoctorCrudRequestedAction>((
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
              title: 'Teaching Workspace',
              message: message,
              role: AcademyRole.doctor,
            ),
          ),
        );
        store.dispatch(DoctorLoadPageAction(action.pageKey, force: true));
      } catch (error) {
        store.dispatch(DoctorPageFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AcademyAppState, DoctorUploadRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final message = await repository.uploadFiles(action.files);
        store.dispatch(
          AcademyToastQueuedAction(
            AcademyToast(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              title: 'Lecture Uploads',
              message: message,
              role: AcademyRole.doctor,
            ),
          ),
        );
        store.dispatch(DoctorLoadPageAction(action.pageKey, force: true));
      } catch (error) {
        store.dispatch(DoctorPageFailedAction(error.toString()));
      }
    }).call,
  ];
}
