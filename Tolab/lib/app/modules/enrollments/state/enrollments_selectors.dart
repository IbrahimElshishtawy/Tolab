import '../../../state/app_state.dart';
import '../models/enrollment_models.dart';
import 'enrollments_state.dart';

EnrollmentsState enrollmentsStateOf(AppState state) => state.enrollmentsState;

List<EnrollmentRecord> selectEnrollmentItems(EnrollmentsState state) =>
    state.items;

EnrollmentLookupBundle selectEnrollmentLookups(EnrollmentsState state) =>
    state.lookups;

EnrollmentDashboardSummary selectEnrollmentSummary(EnrollmentsState state) =>
    state.summary;

List<EnrollmentOfferingOption> selectCourseOfferingsForCourse(
  EnrollmentsState state,
  String? courseId,
) {
  if (courseId == null || courseId.isEmpty) return state.lookups.offerings;
  return state.lookups.offerings
      .where((item) => item.courseId == courseId)
      .toList(growable: false);
}

List<EnrollmentOfferingOption> selectOfferingsForSection(
  EnrollmentsState state,
  String? courseId,
  String? sectionId,
) {
  return selectCourseOfferingsForCourse(state, courseId)
      .where((item) => sectionId == null || item.sectionId == sectionId)
      .toList(growable: false);
}

List<String> selectCourseIds(EnrollmentsState state) {
  return {
    for (final offering in state.lookups.offerings) offering.courseId,
  }.toList(growable: false);
}

bool selectCanGoToPreviousPage(EnrollmentsState state) =>
    state.pagination.page > 1;

bool selectCanGoToNextPage(EnrollmentsState state) =>
    state.pagination.page < state.pagination.totalPages;

int selectSelectedEnrollmentCount(EnrollmentsState state) =>
    state.selectedIds.length;
