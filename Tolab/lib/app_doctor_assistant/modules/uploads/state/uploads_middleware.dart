import 'package:redux/redux.dart';

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
  ];
}
