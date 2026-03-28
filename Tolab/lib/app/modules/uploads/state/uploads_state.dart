import '../../../shared/enums/load_status.dart';
import '../models/upload_model.dart';

class UploadsState {
  const UploadsState({
    this.status = LoadStatus.initial,
    this.previewStatus = LoadStatus.initial,
    this.mutationStatus = LoadStatus.initial,
    this.entities = const <String, UploadItem>{},
    this.orderedIds = const <String>[],
    this.filters = const UploadListFilters(),
    this.sort = const UploadListSort(),
    this.pagination = const UploadPagination(),
    this.lookups = const UploadLookups(),
    this.selectedIds = const <String>{},
    this.viewMode = UploadViewMode.table,
    this.isOffline = false,
    this.totalStorageBytes = 0,
    this.activePreviewId,
    this.previewData,
    this.errorMessage,
    this.feedbackMessage,
  });

  final LoadStatus status;
  final LoadStatus previewStatus;
  final LoadStatus mutationStatus;
  final Map<String, UploadItem> entities;
  final List<String> orderedIds;
  final UploadListFilters filters;
  final UploadListSort sort;
  final UploadPagination pagination;
  final UploadLookups lookups;
  final Set<String> selectedIds;
  final UploadViewMode viewMode;
  final bool isOffline;
  final int totalStorageBytes;
  final String? activePreviewId;
  final UploadPreviewData? previewData;
  final String? errorMessage;
  final String? feedbackMessage;

  UploadsState copyWith({
    LoadStatus? status,
    LoadStatus? previewStatus,
    LoadStatus? mutationStatus,
    Map<String, UploadItem>? entities,
    List<String>? orderedIds,
    UploadListFilters? filters,
    UploadListSort? sort,
    UploadPagination? pagination,
    UploadLookups? lookups,
    Set<String>? selectedIds,
    UploadViewMode? viewMode,
    bool? isOffline,
    int? totalStorageBytes,
    String? activePreviewId,
    bool clearActivePreviewId = false,
    UploadPreviewData? previewData,
    bool clearPreview = false,
    String? errorMessage,
    bool clearError = false,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return UploadsState(
      status: status ?? this.status,
      previewStatus: previewStatus ?? this.previewStatus,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      entities: Map<String, UploadItem>.unmodifiable(entities ?? this.entities),
      orderedIds: List<String>.unmodifiable(orderedIds ?? this.orderedIds),
      filters: filters ?? this.filters,
      sort: sort ?? this.sort,
      pagination: pagination ?? this.pagination,
      lookups: lookups ?? this.lookups,
      selectedIds: Set<String>.unmodifiable(selectedIds ?? this.selectedIds),
      viewMode: viewMode ?? this.viewMode,
      isOffline: isOffline ?? this.isOffline,
      totalStorageBytes: totalStorageBytes ?? this.totalStorageBytes,
      activePreviewId: clearActivePreviewId
          ? null
          : activePreviewId ?? this.activePreviewId,
      previewData: clearPreview ? null : previewData ?? this.previewData,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      feedbackMessage: clearFeedback
          ? null
          : feedbackMessage ?? this.feedbackMessage,
    );
  }
}

const initialUploadsState = UploadsState();
