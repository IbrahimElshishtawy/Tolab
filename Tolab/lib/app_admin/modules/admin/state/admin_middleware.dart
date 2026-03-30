import 'package:redux/redux.dart';

import '../../academy_panel/models/academy_models.dart';
import '../../academy_panel/state/academy_actions.dart';
import '../../academy_panel/state/academy_state.dart';
import '../repositories/admin_repository.dart';
import 'admin_actions.dart';

List<Middleware<AcademyAppState>> createAdminMiddleware(
  AdminRepository repository,
) {
  return [
    TypedMiddleware<AcademyAppState, AdminLoadPageAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final page = await repository.fetchPage(
          action.pageKey,
          notifications: store.state.adminState.notifications,
        );
        store.dispatch(AdminPageLoadedAction(action.pageKey, page));
      } catch (error) {
        store.dispatch(AdminPageFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AcademyAppState, AdminCrudRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final message = action.delete
            ? await repository.deleteRecord(
                action.pageKey,
                action.entityId ?? '',
              )
            : await repository.saveRecord(
                action.pageKey,
                action.payload,
                entityId: action.entityId,
              );
        store.dispatch(
          AcademyToastQueuedAction(
            AcademyToast(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              title: 'Admin Update',
              message: message,
              role: AcademyRole.admin,
            ),
          ),
        );
        store.dispatch(AdminLoadPageAction(action.pageKey, force: true));
      } catch (error) {
        store.dispatch(AdminPageFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AcademyAppState, AdminUploadRequestedAction>((
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
              title: 'Uploads Complete',
              message: message,
              role: AcademyRole.admin,
            ),
          ),
        );
        store.dispatch(AdminLoadPageAction(action.pageKey, force: true));
      } catch (error) {
        store.dispatch(AdminPageFailedAction(error.toString()));
      }
    }).call,
  ];
}
