import 'package:redux/redux.dart';
import 'package:dio/dio.dart';

import '../../../state/app_state.dart';
import '../repositories/uploads_repository.dart';
import 'uploads_actions.dart';

List<Middleware<DoctorAssistantAppState>> createUploadsMiddleware(
  UploadsRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadUploadsAction>(
      (store, action, next) async {
        next(action);
        try {
          final items = await repository.fetchUploads();
          store.dispatch(LoadUploadsSuccessAction(items));
        } catch (error) {
          store.dispatch(LoadUploadsFailureAction(error.toString()));
        }
      },
    ),
    TypedMiddleware<DoctorAssistantAppState, UploadFileAction>(
      (store, action, next) async {
        next(action);
        try {
          await repository.upload(
            formData: action.formData as FormData,
            onSendProgress: (sent, total) {
              final progress = total == 0 ? 0 : sent / total;
              store.dispatch(UploadProgressChangedAction(progress));
            },
          );
          store.dispatch(LoadUploadsAction());
        } catch (error) {
          store.dispatch(LoadUploadsFailureAction(error.toString()));
        }
      },
    ),
  ];
}
