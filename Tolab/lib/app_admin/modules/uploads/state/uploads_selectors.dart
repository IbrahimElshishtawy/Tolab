import '../../../state/app_state.dart';
import '../models/upload_model.dart';

List<UploadItem> selectUploads(AppState state) {
  final uploadsState = state.uploadsState;
  return uploadsState.orderedIds
      .map((id) => uploadsState.entities[id])
      .whereType<UploadItem>()
      .toList(growable: false);
}

List<UploadItem> selectSelectedUploads(AppState state) {
  final uploadsState = state.uploadsState;
  return uploadsState.selectedIds
      .map((id) => uploadsState.entities[id])
      .whereType<UploadItem>()
      .toList(growable: false);
}

UploadMetrics selectUploadMetrics(AppState state) {
  final items = selectUploads(state);
  return UploadMetrics(
    totalCount: items.length,
    uploadedCount: items
        .where((item) => item.status == UploadStatus.uploaded)
        .length,
    uploadingCount: items
        .where((item) => item.status == UploadStatus.uploading)
        .length,
    failedCount: items
        .where((item) => item.status == UploadStatus.failed)
        .length,
    totalStorageBytes: state.uploadsState.totalStorageBytes,
  );
}

bool selectHasActiveSelection(AppState state) =>
    state.uploadsState.selectedIds.isNotEmpty;

UploadItem? selectUploadById(AppState state, String uploadId) =>
    state.uploadsState.entities[uploadId];
