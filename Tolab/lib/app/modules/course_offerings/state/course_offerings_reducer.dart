import '../../../shared/enums/load_status.dart';
import '../models/course_offering_model.dart';
import 'course_offerings_actions.dart';
import 'course_offerings_state.dart';

CourseOfferingsState courseOfferingsReducer(
  CourseOfferingsState state,
  dynamic action,
) {
  switch (action) {
    case FetchCourseOfferingsAction():
      return state.copyWith(
        status: action.silent ? LoadStatus.refreshing : LoadStatus.loading,
        clearError: true,
      );
    case CourseOfferingsLoadedAction():
      final entities = {
        for (final item in action.bundle.offerings) item.id: item,
      };
      final selectedId = state.selectedOfferingId;
      final resolvedSelectedId =
          selectedId != null && entities.containsKey(selectedId)
          ? selectedId
          : action.bundle.offerings.isNotEmpty
          ? action.bundle.offerings.first.id
          : null;
      return state.copyWith(
        status: LoadStatus.success,
        entities: entities,
        orderedIds: action.bundle.offerings.map((item) => item.id).toList(),
        pagination: action.bundle.pagination,
        subjects: action.bundle.subjects,
        doctors: action.bundle.doctors,
        assistants: action.bundle.assistants,
        departments: action.bundle.departments,
        sections: action.bundle.sections,
        selectedOfferingId: resolvedSelectedId,
        clearError: true,
      );
    case CourseOfferingsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    case CourseOfferingsFiltersChangedAction():
      return state.copyWith(
        filters: action.filters,
        pagination: state.pagination.copyWith(page: 1),
      );
    case CourseOfferingsPaginationChangedAction():
      return state.copyWith(pagination: action.pagination);
    case FetchCourseOfferingDetailsAction():
      return state.copyWith(
        detailsStatus: LoadStatus.loading,
        selectedOfferingId: action.offeringId,
        clearError: true,
      );
    case CourseOfferingDetailsLoadedAction():
      final entities = Map<String, CourseOfferingModel>.from(state.entities)
        ..[action.offering.id] = action.offering;
      return state.copyWith(
        detailsStatus: LoadStatus.success,
        entities: entities,
      );
    case CourseOfferingDetailsFailedAction():
      return state.copyWith(
        detailsStatus: LoadStatus.failure,
        errorMessage: action.message,
      );
    case CourseOfferingDetailsTabChangedAction():
      return state.copyWith(activeTab: action.tab);
    case CourseOfferingMutationStartedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.loading,
        clearFeedback: true,
      );
    case CourseOfferingMutationSucceededAction():
      final entities = {
        for (final item in action.result.offerings) item.id: item,
      };
      return state.copyWith(
        mutationStatus: LoadStatus.success,
        entities: entities,
        orderedIds: action.result.offerings.map((item) => item.id).toList(),
        pagination: action.result.pagination,
        feedbackMessage: action.result.message,
        selectedOfferingId:
            action.result.updatedOfferingId ?? state.selectedOfferingId,
      );
    case CourseOfferingMutationFailedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.failure,
        feedbackMessage: action.message,
      );
    case ResetCourseOfferingFeedbackAction():
      return state.copyWith(
        mutationStatus: LoadStatus.initial,
        clearFeedback: true,
      );
    default:
      return state;
  }
}
