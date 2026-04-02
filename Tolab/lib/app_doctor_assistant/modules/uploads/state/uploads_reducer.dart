import '../../../core/state/async_state.dart';
import 'uploads_actions.dart';
import 'uploads_state.dart';

UploadsState uploadsReducer(UploadsState state, dynamic action) {
  switch (action.runtimeType) {
    case LoadUploadsAction:
      return state.copyWith(status: ViewStatus.loading);
    case LoadUploadsSuccessAction:
      return state.copyWith(
        status: ViewStatus.success,
        data: (action as LoadUploadsSuccessAction).items,
        progress: 0,
      );
    case LoadUploadsFailureAction:
      return state.copyWith(
        status: ViewStatus.failure,
        error: (action as LoadUploadsFailureAction).message,
      );
    case UploadProgressChangedAction:
      return state.copyWith(
        status: ViewStatus.loading,
        progress: (action as UploadProgressChangedAction).progress,
      );
    default:
      return state;
  }
}
