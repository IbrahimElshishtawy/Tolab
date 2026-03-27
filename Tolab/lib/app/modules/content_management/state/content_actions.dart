import '../models/content_models.dart';

class LoadContentRequestedAction {
  const LoadContentRequestedAction({this.silent = false});

  final bool silent;
}

class ContentLoadedAction {
  const ContentLoadedAction(this.bundle);

  final ContentRepositoryBundle bundle;
}

class ContentLoadFailedAction {
  const ContentLoadFailedAction(this.message);

  final String message;
}

class ContentFiltersChangedAction {
  const ContentFiltersChangedAction(this.filters);

  final ContentFilters filters;
}

class ContentSortChangedAction {
  const ContentSortChangedAction(this.sort);

  final ContentSort sort;
}

class ContentPaginationChangedAction {
  const ContentPaginationChangedAction(this.pagination);

  final ContentPagination pagination;
}

class ContentSelectionToggledAction {
  const ContentSelectionToggledAction({
    required this.contentId,
    required this.selected,
  });

  final String contentId;
  final bool selected;
}

class ContentVisibleSelectionChangedAction {
  const ContentVisibleSelectionChangedAction({
    required this.visibleIds,
    required this.selected,
  });

  final Set<String> visibleIds;
  final bool selected;
}

class ContentSelectionClearedAction {
  const ContentSelectionClearedAction();
}

class SelectContentAction {
  const SelectContentAction(this.contentId);

  final String? contentId;
}

class ContentDetailsTabChangedAction {
  const ContentDetailsTabChangedAction(this.tab);

  final ContentDetailsTab tab;
}

class PrepareContentDraftAction {
  const PrepareContentDraftAction({this.attachments = const []});

  final List<ContentAttachment> attachments;
}

class ClearContentDraftAction {
  const ClearContentDraftAction();
}

class RemoveDraftAttachmentAction {
  const RemoveDraftAttachmentAction(this.attachmentId);

  final String attachmentId;
}

class UploadDraftFilesRequestedAction {
  const UploadDraftFilesRequestedAction(this.files);

  final List<ContentUploadSource> files;
}

class RetryDraftUploadRequestedAction {
  const RetryDraftUploadRequestedAction(this.taskId);

  final String taskId;
}

class DraftUploadQueuedAction {
  const DraftUploadQueuedAction(this.task);

  final ContentUploadTask task;
}

class DraftUploadProgressChangedAction {
  const DraftUploadProgressChangedAction({
    required this.taskId,
    required this.progress,
  });

  final String taskId;
  final double progress;
}

class DraftUploadCompletedAction {
  const DraftUploadCompletedAction({
    required this.taskId,
    required this.attachment,
  });

  final String taskId;
  final ContentAttachment attachment;
}

class DraftUploadFailedAction {
  const DraftUploadFailedAction({required this.taskId, required this.message});

  final String taskId;
  final String message;
}

class CreateContentRequestedAction {
  const CreateContentRequestedAction({
    required this.payload,
    required this.attachments,
    required this.uploadTasks,
  });

  final ContentUpsertPayload payload;
  final List<ContentAttachment> attachments;
  final List<ContentUploadTask> uploadTasks;
}

class UpdateContentRequestedAction {
  const UpdateContentRequestedAction({
    required this.contentId,
    required this.payload,
    required this.attachments,
    required this.uploadTasks,
  });

  final String contentId;
  final ContentUpsertPayload payload;
  final List<ContentAttachment> attachments;
  final List<ContentUploadTask> uploadTasks;
}

class PublishContentRequestedAction {
  const PublishContentRequestedAction(this.ids);

  final Set<String> ids;
}

class ArchiveContentRequestedAction {
  const ArchiveContentRequestedAction(this.ids);

  final Set<String> ids;
}

class DeleteContentRequestedAction {
  const DeleteContentRequestedAction(this.ids);

  final Set<String> ids;
}

class ContentMutationStartedAction {
  const ContentMutationStartedAction();
}

class ContentMutationCompletedAction {
  const ContentMutationCompletedAction(this.result);

  final ContentMutationResult result;
}

class ContentMutationFailedAction {
  const ContentMutationFailedAction(this.message);

  final String message;
}

class ResetContentMutationMessageAction {
  const ResetContentMutationMessageAction();
}
