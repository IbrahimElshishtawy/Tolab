import '../../../shared/enums/load_status.dart';
import '../models/upload_model.dart';
import 'uploads_actions.dart';
import 'uploads_state.dart';

UploadsState uploadsReducer(UploadsState state, dynamic action) {
  switch (action) {
    case FetchUploadsAction():
      return state.copyWith(
        status: action.silent ? LoadStatus.refreshing : LoadStatus.loading,
        clearError: true,
      );
    case UploadsLoadedAction():
      final mergedEntities = _mergeFetchedItems(
        state,
        action.result.bundle.items,
      );
      final orderedIds = _buildOrderedIds(
        mergedEntities.values.toList(growable: false),
      );
      return state.copyWith(
        status: LoadStatus.success,
        entities: mergedEntities,
        orderedIds: orderedIds,
        pagination: action.result.bundle.pagination,
        lookups: action.result.bundle.lookups,
        isOffline: action.result.isOffline,
        totalStorageBytes: action.result.bundle.totalStorageBytes,
        feedbackMessage: action.result.feedbackMessage,
        clearError: true,
      );
    case UploadsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    case UploadsFiltersChangedAction():
      return state.copyWith(
        filters: action.filters,
        pagination: state.pagination.copyWith(page: 1),
      );
    case UploadsSortChangedAction():
      return state.copyWith(sort: action.sort);
    case UploadsPaginationChangedAction():
      return state.copyWith(pagination: action.pagination);
    case UploadsViewModeChangedAction():
      return state.copyWith(viewMode: action.viewMode);
    case UploadsSelectionChangedAction():
      return state.copyWith(selectedIds: action.selectedIds);
    case UploadsSelectionToggledAction():
      final selected = Set<String>.from(state.selectedIds);
      if (selected.contains(action.uploadId)) {
        selected.remove(action.uploadId);
      } else {
        selected.add(action.uploadId);
      }
      return state.copyWith(selectedIds: selected);
    case UploadsSelectionClearedAction():
      return state.copyWith(selectedIds: const <String>{});
    case UploadsQueuedAction():
      final entities = Map<String, UploadItem>.from(state.entities);
      for (final item in action.items) {
        entities[item.id] = item;
      }
      return state.copyWith(
        entities: entities,
        orderedIds: _buildOrderedIds(entities.values.toList(growable: false)),
        mutationStatus: LoadStatus.loading,
        clearFeedback: true,
      );
    case UploadProgressUpdatedAction():
      final item = state.entities[action.uploadId];
      if (item == null) return state;
      final entities = Map<String, UploadItem>.from(state.entities)
        ..[action.uploadId] = item.copyWith(
          progress: action.progress.clamp(0.0, 1.0).toDouble(),
          status: UploadStatus.uploading,
          clearError: true,
        );
      return state.copyWith(entities: entities);
    case UploadItemSucceededAction():
      final entities = Map<String, UploadItem>.from(state.entities)
        ..remove(action.localId)
        ..[action.item.id] = action.item.copyWith(
          status: UploadStatus.uploaded,
          progress: 1,
          clearError: true,
        );
      final selected = Set<String>.from(state.selectedIds)
        ..remove(action.localId);
      return state.copyWith(
        entities: entities,
        orderedIds: _buildOrderedIds(entities.values.toList(growable: false)),
        selectedIds: selected,
        mutationStatus: LoadStatus.success,
        totalStorageBytes: state.totalStorageBytes + action.item.sizeBytes,
        feedbackMessage: action.message ?? 'Upload finished successfully.',
      );
    case UploadItemFailedAction():
      final current = state.entities[action.uploadId];
      if (current == null) return state;
      final entities = Map<String, UploadItem>.from(state.entities)
        ..[action.uploadId] = current.copyWith(
          status: action.cancelled
              ? UploadStatus.cancelled
              : UploadStatus.failed,
          errorMessage: action.message,
        );
      return state.copyWith(
        entities: entities,
        mutationStatus: LoadStatus.failure,
        feedbackMessage: action.message,
      );
    case DeleteUploadsSucceededAction():
      final entities = Map<String, UploadItem>.from(state.entities)
        ..removeWhere((key, _) => action.deletedIds.contains(key));
      return state.copyWith(
        entities: entities,
        orderedIds: _buildOrderedIds(entities.values.toList(growable: false)),
        selectedIds: const <String>{},
        pagination: action.result.pagination,
        mutationStatus: LoadStatus.success,
        feedbackMessage: action.result.message,
      );
    case DeleteUploadsFailedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.failure,
        feedbackMessage: action.message,
      );
    case AssignUploadsSucceededAction():
      final currentEntities = Map<String, UploadItem>.from(state.entities);
      for (final item in action.result.items) {
        currentEntities[item.id] = item;
      }
      return state.copyWith(
        entities: currentEntities,
        orderedIds: _buildOrderedIds(
          currentEntities.values.toList(growable: false),
        ),
        mutationStatus: LoadStatus.success,
        feedbackMessage: action.result.message,
      );
    case AssignUploadsFailedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.failure,
        feedbackMessage: action.message,
      );
    case OpenUploadPreviewAction():
      return state.copyWith(
        previewStatus: LoadStatus.loading,
        activePreviewId: action.uploadId,
        clearPreview: true,
        clearError: true,
      );
    case UploadPreviewLoadedAction():
      return state.copyWith(
        previewStatus: LoadStatus.success,
        previewData: action.preview,
        activePreviewId: action.preview.uploadId,
      );
    case UploadPreviewFailedAction():
      return state.copyWith(
        previewStatus: LoadStatus.failure,
        errorMessage: action.message,
      );
    case CloseUploadPreviewAction():
      return state.copyWith(
        previewStatus: LoadStatus.initial,
        clearActivePreviewId: true,
        clearPreview: true,
      );
    case UploadsFeedbackClearedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.initial,
        clearFeedback: true,
      );
    default:
      return state;
  }
}

Map<String, UploadItem> _mergeFetchedItems(
  UploadsState state,
  List<UploadItem> fetchedItems,
) {
  final entities = <String, UploadItem>{
    for (final item in fetchedItems) item.id: item,
  };

  for (final item in state.entities.values) {
    if (item.isUploading ||
        item.isFailed ||
        item.status == UploadStatus.cancelled) {
      entities[item.id] = item;
    }
  }
  return Map<String, UploadItem>.unmodifiable(entities);
}

List<String> _buildOrderedIds(List<UploadItem> items) {
  items.sort((left, right) => right.uploadedAt.compareTo(left.uploadedAt));
  return List<String>.unmodifiable(items.map((item) => item.id));
}
