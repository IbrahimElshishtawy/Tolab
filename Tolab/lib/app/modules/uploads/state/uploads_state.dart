import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/content_models.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef UploadsState = EntityCollectionState<UploadItem>;

const UploadsState initialUploadsState = EntityCollectionState<UploadItem>();

class LoadUploadsAction {}

class UploadsLoadedAction {
  UploadsLoadedAction(this.items);

  final List<UploadItem> items;
}

class UploadsFailedAction {
  UploadsFailedAction(this.message);

  final String message;
}

UploadsState uploadsReducer(UploadsState state, dynamic action) {
  switch (action) {
    case LoadUploadsAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case UploadsLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case UploadsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createUploadsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadUploadsAction>((store, action, next) async {
      next(action);
      try {
        store.dispatch(
          UploadsLoadedAction(await deps.uploadsRepository.fetchUploads()),
        );
      } catch (error) {
        store.dispatch(UploadsFailedAction(error.toString()));
      }
    }).call,
  ];
}
