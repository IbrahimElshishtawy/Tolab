import 'package:flutter/foundation.dart';

import '../models/upload_model.dart';

class FetchUploadsAction {
  const FetchUploadsAction({this.silent = false});

  final bool silent;
}

class UploadsLoadedAction {
  const UploadsLoadedAction(this.result);

  final UploadFetchResult result;
}

class UploadsFailedAction {
  const UploadsFailedAction(this.message);

  final String message;
}

class UploadsFiltersChangedAction {
  const UploadsFiltersChangedAction(this.filters);

  final UploadListFilters filters;
}

class UploadsSortChangedAction {
  const UploadsSortChangedAction(this.sort);

  final UploadListSort sort;
}

class UploadsPaginationChangedAction {
  const UploadsPaginationChangedAction(this.pagination);

  final UploadPagination pagination;
}

class UploadsViewModeChangedAction {
  const UploadsViewModeChangedAction(this.viewMode);

  final UploadViewMode viewMode;
}

class UploadsSelectionChangedAction {
  const UploadsSelectionChangedAction(this.selectedIds);

  final Set<String> selectedIds;
}

class UploadsSelectionToggledAction {
  const UploadsSelectionToggledAction(this.uploadId);

  final String uploadId;
}

class UploadsSelectionClearedAction {
  const UploadsSelectionClearedAction();
}

class UploadFilesAction {
  const UploadFilesAction({
    required this.files,
    this.assignment = const UploadAssignmentPayload(),
  });

  final List<UploadLocalFile> files;
  final UploadAssignmentPayload assignment;
}

class UploadsQueuedAction {
  const UploadsQueuedAction(this.items);

  final List<UploadItem> items;
}

class UploadProgressUpdatedAction {
  const UploadProgressUpdatedAction({
    required this.uploadId,
    required this.progress,
  });

  final String uploadId;
  final double progress;
}

class UploadItemSucceededAction {
  const UploadItemSucceededAction({
    required this.localId,
    required this.item,
    this.message,
  });

  final String localId;
  final UploadItem item;
  final String? message;
}

class UploadItemFailedAction {
  const UploadItemFailedAction({
    required this.uploadId,
    required this.message,
    this.cancelled = false,
  });

  final String uploadId;
  final String message;
  final bool cancelled;
}

class RetryUploadAction {
  const RetryUploadAction(this.uploadId);

  final String uploadId;
}

class CancelUploadAction {
  const CancelUploadAction(this.uploadId);

  final String uploadId;
}

class DeleteUploadsAction {
  const DeleteUploadsAction(this.uploadIds);

  final Set<String> uploadIds;
}

class DeleteUploadsSucceededAction {
  const DeleteUploadsSucceededAction(this.result, this.deletedIds);

  final UploadMutationResult result;
  final Set<String> deletedIds;
}

class DeleteUploadsFailedAction {
  const DeleteUploadsFailedAction(this.message);

  final String message;
}

class AssignUploadsAction {
  const AssignUploadsAction({required this.uploadIds, required this.payload});

  final Set<String> uploadIds;
  final UploadAssignmentPayload payload;
}

class AssignUploadsSucceededAction {
  const AssignUploadsSucceededAction(this.result);

  final UploadMutationResult result;
}

class AssignUploadsFailedAction {
  const AssignUploadsFailedAction(this.message);

  final String message;
}

class OpenUploadPreviewAction {
  const OpenUploadPreviewAction(this.uploadId);

  final String uploadId;
}

class UploadPreviewLoadedAction {
  const UploadPreviewLoadedAction(this.preview);

  final UploadPreviewData preview;
}

class UploadPreviewFailedAction {
  const UploadPreviewFailedAction(this.message);

  final String message;
}

class CloseUploadPreviewAction {
  const CloseUploadPreviewAction();
}

class UploadsFeedbackClearedAction {
  const UploadsFeedbackClearedAction();
}

class DownloadUploadsAction {
  const DownloadUploadsAction({
    required this.uploadIds,
    this.onResolved,
    this.onError,
  });

  final Set<String> uploadIds;
  final ValueChanged<List<UploadItem>>? onResolved;
  final ValueChanged<String>? onError;
}
