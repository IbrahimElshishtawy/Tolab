import '../../../shared/enums/load_status.dart';
import '../models/content_models.dart';
import 'content_actions.dart';
import 'content_state.dart';

ContentState contentReducer(ContentState state, dynamic action) {
  switch (action) {
    case LoadContentRequestedAction():
      return state.copyWith(
        status: action.silent ? state.status : LoadStatus.loading,
        clearError: true,
      );
    case ContentLoadedAction():
      final entities = {for (final item in action.bundle.items) item.id: item};
      final selectedId = state.selectedContentId;
      final resolvedSelectedId = entities.containsKey(selectedId)
          ? selectedId
          : action.bundle.items.isEmpty
          ? null
          : action.bundle.items.first.id;
      return state.copyWith(
        status: LoadStatus.success,
        entities: entities,
        orderedIds: action.bundle.items.map((item) => item.id).toList(),
        subjects: action.bundle.subjects,
        sections: action.bundle.sections,
        instructors: action.bundle.instructors,
        selectedContentId: resolvedSelectedId,
        clearError: true,
      );
    case ContentLoadFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    case ContentFiltersChangedAction():
      return state.copyWith(
        filters: action.filters,
        pagination: state.pagination.copyWith(page: 1),
      );
    case ContentSortChangedAction():
      return state.copyWith(
        sort: action.sort,
        pagination: state.pagination.copyWith(page: 1),
      );
    case ContentPaginationChangedAction():
      return state.copyWith(pagination: action.pagination);
    case ContentSelectionToggledAction():
      final nextSelection = Set<String>.from(state.selectedIds);
      if (action.selected) {
        nextSelection.add(action.contentId);
      } else {
        nextSelection.remove(action.contentId);
      }
      return state.copyWith(selectedIds: nextSelection);
    case ContentVisibleSelectionChangedAction():
      final nextSelection = Set<String>.from(state.selectedIds);
      if (action.selected) {
        nextSelection.addAll(action.visibleIds);
      } else {
        nextSelection.removeAll(action.visibleIds);
      }
      return state.copyWith(selectedIds: nextSelection);
    case ContentSelectionClearedAction():
      return state.copyWith(selectedIds: const <String>{});
    case SelectContentAction():
      return state.copyWith(selectedContentId: action.contentId);
    case ContentDetailsTabChangedAction():
      return state.copyWith(activeDetailsTab: action.tab);
    case PrepareContentDraftAction():
      return state.copyWith(
        draftAttachments: action.attachments,
        uploadTasks: const <String, ContentUploadTask>{},
      );
    case ClearContentDraftAction():
      return state.copyWith(
        draftAttachments: const <ContentAttachment>[],
        uploadTasks: const <String, ContentUploadTask>{},
      );
    case RemoveDraftAttachmentAction():
      final nextDrafts = state.draftAttachments
          .where((item) => item.id != action.attachmentId)
          .toList(growable: false);
      final nextTasks = Map<String, ContentUploadTask>.from(state.uploadTasks)
        ..removeWhere((_, task) => task.attachment?.id == action.attachmentId);
      return state.copyWith(
        draftAttachments: nextDrafts,
        uploadTasks: nextTasks,
      );
    case DraftUploadQueuedAction():
      final nextTasks = Map<String, ContentUploadTask>.from(state.uploadTasks)
        ..[action.task.id] = action.task;
      return state.copyWith(uploadTasks: nextTasks);
    case DraftUploadProgressChangedAction():
      final existing = state.uploadTasks[action.taskId];
      if (existing == null) return state;
      final nextTasks = Map<String, ContentUploadTask>.from(state.uploadTasks)
        ..[action.taskId] = existing.copyWith(
          progress: action.progress,
          statusLabel: action.progress >= 1 ? 'Processing' : 'Uploading',
        );
      return state.copyWith(uploadTasks: nextTasks);
    case DraftUploadCompletedAction():
      final existing = state.uploadTasks[action.taskId];
      if (existing == null) return state;
      final nextTasks = Map<String, ContentUploadTask>.from(state.uploadTasks)
        ..[action.taskId] = existing.copyWith(
          progress: 1,
          statusLabel: 'Completed',
          attachment: action.attachment,
          clearError: true,
        );
      return state.copyWith(
        uploadTasks: nextTasks,
        draftAttachments: [...state.draftAttachments, action.attachment],
      );
    case DraftUploadFailedAction():
      final existing = state.uploadTasks[action.taskId];
      if (existing == null) return state;
      final nextTasks = Map<String, ContentUploadTask>.from(state.uploadTasks)
        ..[action.taskId] = existing.copyWith(
          statusLabel: 'Failed',
          errorMessage: action.message,
        );
      return state.copyWith(uploadTasks: nextTasks);
    case ContentMutationStartedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.loading,
        clearMutationMessage: true,
      );
    case ContentMutationCompletedAction():
      final entities = {for (final item in action.result.items) item.id: item};
      return state.copyWith(
        mutationStatus: LoadStatus.success,
        entities: entities,
        orderedIds: action.result.items.map((item) => item.id).toList(),
        mutationMessage: action.result.message,
        selectedContentId:
            action.result.selectedContentId ?? state.selectedContentId,
        selectedIds: const <String>{},
        draftAttachments: const <ContentAttachment>[],
        uploadTasks: const <String, ContentUploadTask>{},
      );
    case ContentMutationFailedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.failure,
        mutationMessage: action.message,
      );
    case ResetContentMutationMessageAction():
      return state.copyWith(
        mutationStatus: LoadStatus.initial,
        clearMutationMessage: true,
      );
    default:
      return state;
  }
}
