import '../../../shared/enums/load_status.dart';
import '../models/course_offering_model.dart';

class CourseOfferingsState {
  const CourseOfferingsState({
    this.status = LoadStatus.initial,
    this.detailsStatus = LoadStatus.initial,
    this.mutationStatus = LoadStatus.initial,
    this.entities = const <String, CourseOfferingModel>{},
    this.orderedIds = const <String>[],
    this.filters = const CourseOfferingsFilters(),
    this.pagination = const CourseOfferingsPagination(),
    this.subjects = const <CourseOfferingLookupOption>[],
    this.doctors = const <CourseOfferingLookupOption>[],
    this.assistants = const <CourseOfferingLookupOption>[],
    this.departments = const <CourseOfferingLookupOption>[],
    this.sections = const <CourseOfferingLookupOption>[],
    this.activeTab = CourseOfferingDetailsTab.overview,
    this.selectedOfferingId,
    this.errorMessage,
    this.feedbackMessage,
  });

  final LoadStatus status;
  final LoadStatus detailsStatus;
  final LoadStatus mutationStatus;
  final Map<String, CourseOfferingModel> entities;
  final List<String> orderedIds;
  final CourseOfferingsFilters filters;
  final CourseOfferingsPagination pagination;
  final List<CourseOfferingLookupOption> subjects;
  final List<CourseOfferingLookupOption> doctors;
  final List<CourseOfferingLookupOption> assistants;
  final List<CourseOfferingLookupOption> departments;
  final List<CourseOfferingLookupOption> sections;
  final CourseOfferingDetailsTab activeTab;
  final String? selectedOfferingId;
  final String? errorMessage;
  final String? feedbackMessage;

  CourseOfferingsState copyWith({
    LoadStatus? status,
    LoadStatus? detailsStatus,
    LoadStatus? mutationStatus,
    Map<String, CourseOfferingModel>? entities,
    List<String>? orderedIds,
    CourseOfferingsFilters? filters,
    CourseOfferingsPagination? pagination,
    List<CourseOfferingLookupOption>? subjects,
    List<CourseOfferingLookupOption>? doctors,
    List<CourseOfferingLookupOption>? assistants,
    List<CourseOfferingLookupOption>? departments,
    List<CourseOfferingLookupOption>? sections,
    CourseOfferingDetailsTab? activeTab,
    String? selectedOfferingId,
    bool clearSelectedOfferingId = false,
    String? errorMessage,
    bool clearError = false,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return CourseOfferingsState(
      status: status ?? this.status,
      detailsStatus: detailsStatus ?? this.detailsStatus,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      entities: Map<String, CourseOfferingModel>.unmodifiable(
        entities ?? this.entities,
      ),
      orderedIds: List<String>.unmodifiable(orderedIds ?? this.orderedIds),
      filters: filters ?? this.filters,
      pagination: pagination ?? this.pagination,
      subjects: List<CourseOfferingLookupOption>.unmodifiable(
        subjects ?? this.subjects,
      ),
      doctors: List<CourseOfferingLookupOption>.unmodifiable(
        doctors ?? this.doctors,
      ),
      assistants: List<CourseOfferingLookupOption>.unmodifiable(
        assistants ?? this.assistants,
      ),
      departments: List<CourseOfferingLookupOption>.unmodifiable(
        departments ?? this.departments,
      ),
      sections: List<CourseOfferingLookupOption>.unmodifiable(
        sections ?? this.sections,
      ),
      activeTab: activeTab ?? this.activeTab,
      selectedOfferingId: clearSelectedOfferingId
          ? null
          : selectedOfferingId ?? this.selectedOfferingId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      feedbackMessage: clearFeedback
          ? null
          : feedbackMessage ?? this.feedbackMessage,
    );
  }
}

const initialCourseOfferingsState = CourseOfferingsState();
