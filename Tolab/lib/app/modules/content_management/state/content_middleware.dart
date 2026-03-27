import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../state/app_state.dart';
import '../models/content_models.dart';
import 'content_actions.dart';

List<Middleware<AppState>> createContentMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadContentRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final bundle = await deps.contentRepository.fetchContentBundle();
        store.dispatch(ContentLoadedAction(bundle));
      } catch (error) {
        store.dispatch(ContentLoadFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, UploadDraftFilesRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      for (final file in action.files) {
        final taskId =
            'task-${DateTime.now().microsecondsSinceEpoch}-${file.name}';
        store.dispatch(DraftUploadQueuedAction(_queuedTask(taskId, file)));
        try {
          final attachment = await deps.contentRepository.uploadAttachment(
            file,
            onProgress: (progress) => store.dispatch(
              DraftUploadProgressChangedAction(
                taskId: taskId,
                progress: progress,
              ),
            ),
          );
          store.dispatch(
            DraftUploadCompletedAction(taskId: taskId, attachment: attachment),
          );
        } catch (error) {
          store.dispatch(
            DraftUploadFailedAction(taskId: taskId, message: error.toString()),
          );
        }
      }
    }).call,
    TypedMiddleware<AppState, RetryDraftUploadRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      final source =
          store.state.contentState.uploadTasks[action.taskId]?.source;
      if (source == null) return;
      store.dispatch(UploadDraftFilesRequestedAction([source]));
    }).call,
    TypedMiddleware<AppState, CreateContentRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const ContentMutationStartedAction());
      try {
        final result = await deps.contentRepository.createContent(
          payload: action.payload,
          attachments: action.attachments,
          uploadTasks: action.uploadTasks,
        );
        store.dispatch(ContentMutationCompletedAction(result));
      } catch (error) {
        store.dispatch(ContentMutationFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, UpdateContentRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const ContentMutationStartedAction());
      try {
        final result = await deps.contentRepository.updateContent(
          contentId: action.contentId,
          payload: action.payload,
          attachments: action.attachments,
          uploadTasks: action.uploadTasks,
        );
        store.dispatch(ContentMutationCompletedAction(result));
      } catch (error) {
        store.dispatch(ContentMutationFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, PublishContentRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const ContentMutationStartedAction());
      try {
        final result = await deps.contentRepository.setStatus(
          action.ids,
          ContentStatus.published,
        );
        store.dispatch(ContentMutationCompletedAction(result));
      } catch (error) {
        store.dispatch(ContentMutationFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, ArchiveContentRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const ContentMutationStartedAction());
      try {
        final result = await deps.contentRepository.setStatus(
          action.ids,
          ContentStatus.archived,
        );
        store.dispatch(ContentMutationCompletedAction(result));
      } catch (error) {
        store.dispatch(ContentMutationFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, DeleteContentRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const ContentMutationStartedAction());
      try {
        final result = await deps.contentRepository.deleteContent(action.ids);
        store.dispatch(ContentMutationCompletedAction(result));
      } catch (error) {
        store.dispatch(ContentMutationFailedAction(error.toString()));
      }
    }).call,
  ];
}

ContentUploadTask _queuedTask(String taskId, ContentUploadSource source) {
  return ContentUploadTask(
    id: taskId,
    source: source,
    progress: 0,
    statusLabel: 'Queued',
  );
}
