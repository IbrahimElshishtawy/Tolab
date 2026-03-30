import '../../../shared/enums/load_status.dart';
import '../models/content_models.dart';

class ContentState {
  const ContentState({
    this.status = LoadStatus.initial,
    this.mutationStatus = LoadStatus.initial,
    this.entities = const <String, ContentRecord>{},
    this.orderedIds = const <String>[],
    this.subjects = const <ContentSubjectOption>[],
    this.sections = const <ContentSectionOption>[],
    this.instructors = const <ContentInstructorOption>[],
    this.filters = const ContentFilters(),
    this.sort = const ContentSort(),
    this.pagination = const ContentPagination(),
    this.selectedIds = const <String>{},
    this.activeDetailsTab = ContentDetailsTab.overview,
    this.draftAttachments = const <ContentAttachment>[],
    this.uploadTasks = const <String, ContentUploadTask>{},
    this.selectedContentId,
    this.errorMessage,
    this.mutationMessage,
  });

  final LoadStatus status;
  final LoadStatus mutationStatus;
  final Map<String, ContentRecord> entities;
  final List<String> orderedIds;
  final List<ContentSubjectOption> subjects;
  final List<ContentSectionOption> sections;
  final List<ContentInstructorOption> instructors;
  final ContentFilters filters;
  final ContentSort sort;
  final ContentPagination pagination;
  final Set<String> selectedIds;
  final ContentDetailsTab activeDetailsTab;
  final List<ContentAttachment> draftAttachments;
  final Map<String, ContentUploadTask> uploadTasks;
  final String? selectedContentId;
  final String? errorMessage;
  final String? mutationMessage;

  ContentState copyWith({
    LoadStatus? status,
    LoadStatus? mutationStatus,
    Map<String, ContentRecord>? entities,
    List<String>? orderedIds,
    List<ContentSubjectOption>? subjects,
    List<ContentSectionOption>? sections,
    List<ContentInstructorOption>? instructors,
    ContentFilters? filters,
    ContentSort? sort,
    ContentPagination? pagination,
    Set<String>? selectedIds,
    ContentDetailsTab? activeDetailsTab,
    List<ContentAttachment>? draftAttachments,
    Map<String, ContentUploadTask>? uploadTasks,
    String? selectedContentId,
    bool clearSelectedContentId = false,
    String? errorMessage,
    bool clearError = false,
    String? mutationMessage,
    bool clearMutationMessage = false,
  }) {
    return ContentState(
      status: status ?? this.status,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      entities: Map<String, ContentRecord>.unmodifiable(
        entities ?? this.entities,
      ),
      orderedIds: List<String>.unmodifiable(orderedIds ?? this.orderedIds),
      subjects: List<ContentSubjectOption>.unmodifiable(
        subjects ?? this.subjects,
      ),
      sections: List<ContentSectionOption>.unmodifiable(
        sections ?? this.sections,
      ),
      instructors: List<ContentInstructorOption>.unmodifiable(
        instructors ?? this.instructors,
      ),
      filters: filters ?? this.filters,
      sort: sort ?? this.sort,
      pagination: pagination ?? this.pagination,
      selectedIds: Set<String>.unmodifiable(selectedIds ?? this.selectedIds),
      activeDetailsTab: activeDetailsTab ?? this.activeDetailsTab,
      draftAttachments: List<ContentAttachment>.unmodifiable(
        draftAttachments ?? this.draftAttachments,
      ),
      uploadTasks: Map<String, ContentUploadTask>.unmodifiable(
        uploadTasks ?? this.uploadTasks,
      ),
      selectedContentId: clearSelectedContentId
          ? null
          : selectedContentId ?? this.selectedContentId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      mutationMessage: clearMutationMessage
          ? null
          : mutationMessage ?? this.mutationMessage,
    );
  }
}

const initialContentState = ContentState();
