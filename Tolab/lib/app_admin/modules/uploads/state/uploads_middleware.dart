import 'package:redux/redux.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_dependencies.dart';
import '../../../state/app_state.dart';
import '../models/upload_model.dart';
import 'uploads_actions.dart';

List<Middleware<AppState>> createUploadsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, FetchUploadsAction>((store, action, next) async {
      next(action);
      try {
        final uploadsState = store.state.uploadsState;
        final result = await deps.uploadsRepository.fetchUploads(
          filters: uploadsState.filters,
          sort: uploadsState.sort,
          pagination: uploadsState.pagination,
        );
        store.dispatch(UploadsLoadedAction(result));
      } catch (error) {
        store.dispatch(UploadsFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, UploadsFiltersChangedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const FetchUploadsAction(silent: true));
    }).call,
    TypedMiddleware<AppState, UploadsSortChangedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const FetchUploadsAction(silent: true));
    }).call,
    TypedMiddleware<AppState, UploadsPaginationChangedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const FetchUploadsAction(silent: true));
    }).call,
    TypedMiddleware<AppState, UploadFilesAction>((store, action, next) async {
      next(action);
      final userName =
          store.state.authState.currentUser?.name ?? 'Administrator';
      final queuedItems = action.files
          .map(
            (file) => UploadItem.local(
              file: file,
              uploadedBy: userName,
              assignment: UploadAssignment(
                courseId: action.assignment.courseId,
                sectionId: action.assignment.sectionId,
                subjectId: action.assignment.subjectId,
                academicYear: action.assignment.academicYear,
              ),
              accessControl: action.assignment.accessControl,
            ),
          )
          .toList(growable: false);
      store.dispatch(UploadsQueuedAction(queuedItems));

      for (final file in action.files) {
        try {
          final item = await deps.uploadsRepository.uploadFile(
            file,
            assignment: action.assignment,
            uploadedBy: userName,
            onProgress: (progress) {
              store.dispatch(
                UploadProgressUpdatedAction(
                  uploadId: file.localId,
                  progress: progress,
                ),
              );
            },
          );
          store.dispatch(
            UploadItemSucceededAction(
              localId: file.localId,
              item: item,
              message: '${file.name} uploaded successfully.',
            ),
          );
        } catch (error) {
          final message = _messageOf(error);
          store.dispatch(
            UploadItemFailedAction(
              uploadId: file.localId,
              message: message,
              cancelled: message.toLowerCase().contains('cancelled'),
            ),
          );
        }
      }
    }).call,
    TypedMiddleware<AppState, RetryUploadAction>((store, action, next) async {
      next(action);
      final state = store.state.uploadsState;
      final item = state.entities[action.uploadId];
      final localFile = item?.localFile;
      if (item == null || localFile == null) {
        store.dispatch(
          UploadItemFailedAction(
            uploadId: action.uploadId,
            message: 'The original file is no longer available for retry.',
          ),
        );
        return;
      }
      store.dispatch(
        UploadProgressUpdatedAction(uploadId: action.uploadId, progress: 0),
      );
      try {
        final uploaded = await deps.uploadsRepository.uploadFile(
          localFile,
          assignment: UploadAssignmentPayload(
            courseId: item.assignment.courseId,
            sectionId: item.assignment.sectionId,
            subjectId: item.assignment.subjectId,
            academicYear: item.assignment.academicYear,
            accessControl: item.accessControl,
          ),
          uploadedBy: item.uploadedBy,
          onProgress: (progress) {
            store.dispatch(
              UploadProgressUpdatedAction(
                uploadId: action.uploadId,
                progress: progress,
              ),
            );
          },
        );
        store.dispatch(
          UploadItemSucceededAction(
            localId: action.uploadId,
            item: uploaded,
            message: '${item.name} uploaded successfully.',
          ),
        );
      } catch (error) {
        store.dispatch(
          UploadItemFailedAction(
            uploadId: action.uploadId,
            message: _messageOf(error),
          ),
        );
      }
    }).call,
    TypedMiddleware<AppState, CancelUploadAction>((store, action, next) async {
      next(action);
      deps.uploadsRepository.cancelUpload(action.uploadId);
      store.dispatch(
        UploadItemFailedAction(
          uploadId: action.uploadId,
          message: 'Upload cancelled.',
          cancelled: true,
        ),
      );
    }).call,
    TypedMiddleware<AppState, DeleteUploadsAction>((store, action, next) async {
      next(action);
      try {
        final state = store.state.uploadsState;
        final result = await deps.uploadsRepository.deleteUploads(
          action.uploadIds,
          filters: state.filters,
          sort: state.sort,
          pagination: state.pagination,
        );
        store.dispatch(DeleteUploadsSucceededAction(result, action.uploadIds));
      } catch (error) {
        store.dispatch(DeleteUploadsFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, AssignUploadsAction>((store, action, next) async {
      next(action);
      try {
        final state = store.state.uploadsState;
        final result = await deps.uploadsRepository.assignUploads(
          action.uploadIds,
          action.payload,
          filters: state.filters,
          sort: state.sort,
          pagination: state.pagination,
        );
        store.dispatch(AssignUploadsSucceededAction(result));
      } catch (error) {
        store.dispatch(AssignUploadsFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, OpenUploadPreviewAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final preview = await deps.uploadsRepository.fetchPreview(
          action.uploadId,
        );
        store.dispatch(UploadPreviewLoadedAction(preview));
      } catch (error) {
        store.dispatch(UploadPreviewFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, DownloadUploadsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final items = deps.uploadsRepository.itemsByIds(action.uploadIds);
        action.onResolved?.call(items);
      } catch (error) {
        action.onError?.call(_messageOf(error));
      }
    }).call,
  ];
}

String _messageOf(Object error) {
  if (error is AppException) return error.message;
  return error.toString();
}
