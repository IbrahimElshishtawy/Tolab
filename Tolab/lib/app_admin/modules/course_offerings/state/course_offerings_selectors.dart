import 'dart:math' as math;

import '../../../state/app_state.dart';
import '../models/course_offering_model.dart';
import 'course_offerings_state.dart';

class CourseOfferingsDashboardMetrics {
  const CourseOfferingsDashboardMetrics({
    required this.total,
    required this.active,
    required this.averageFillRate,
    required this.totalSeatsRemaining,
  });

  final int total;
  final int active;
  final double averageFillRate;
  final int totalSeatsRemaining;
}

CourseOfferingsState courseOfferingsStateOf(AppState state) =>
    state.courseOfferingsState;

List<CourseOfferingModel> selectAllOfferings(CourseOfferingsState state) {
  return state.orderedIds
      .map((id) => state.entities[id])
      .whereType<CourseOfferingModel>()
      .toList(growable: false);
}

List<CourseOfferingModel> selectFilteredOfferings(CourseOfferingsState state) {
  final query = state.filters.searchQuery.trim().toLowerCase();
  return selectAllOfferings(state)
      .where((offering) {
        final matchesQuery =
            query.isEmpty ||
            offering.subjectName.toLowerCase().contains(query) ||
            offering.code.toLowerCase().contains(query) ||
            offering.sectionName.toLowerCase().contains(query) ||
            offering.doctor.name.toLowerCase().contains(query);
        final matchesSemester =
            state.filters.semester == null ||
            offering.semester.toLowerCase() ==
                state.filters.semester!.toLowerCase();
        final matchesDepartment =
            state.filters.departmentId == null ||
            offering.departmentId == state.filters.departmentId;
        final matchesStatus =
            state.filters.status == null ||
            offering.status == state.filters.status;
        return matchesQuery &&
            matchesSemester &&
            matchesDepartment &&
            matchesStatus;
      })
      .toList(growable: false);
}

List<CourseOfferingModel> selectVisibleOfferings(CourseOfferingsState state) {
  final filtered = selectFilteredOfferings(state);
  final start = math.min(
    filtered.length,
    math.max(0, state.pagination.page - 1) * state.pagination.perPage,
  );
  final end = math.min(filtered.length, start + state.pagination.perPage);
  return List<CourseOfferingModel>.unmodifiable(filtered.sublist(start, end));
}

int selectFilteredTotalPages(CourseOfferingsState state) {
  final total = selectFilteredOfferings(state).length;
  if (total == 0) return 1;
  return (total / state.pagination.perPage).ceil();
}

CourseOfferingModel? selectOfferingById(
  CourseOfferingsState state,
  String? offeringId,
) {
  if (offeringId == null) return null;
  return state.entities[offeringId];
}

CourseOfferingModel? selectSelectedOffering(CourseOfferingsState state) {
  return selectOfferingById(state, state.selectedOfferingId);
}

CourseOfferingsDashboardMetrics selectCourseOfferingsMetrics(
  CourseOfferingsState state,
) {
  final offerings = selectFilteredOfferings(state);
  if (offerings.isEmpty) {
    return const CourseOfferingsDashboardMetrics(
      total: 0,
      active: 0,
      averageFillRate: 0,
      totalSeatsRemaining: 0,
    );
  }
  final averageFillRate =
      offerings.fold<double>(0, (sum, item) => sum + item.fillRate) /
      offerings.length;
  return CourseOfferingsDashboardMetrics(
    total: offerings.length,
    active: offerings
        .where((item) => item.status == CourseOfferingStatus.active)
        .length,
    averageFillRate: averageFillRate,
    totalSeatsRemaining: offerings.fold<int>(
      0,
      (sum, item) => sum + item.seatsRemaining,
    ),
  );
}

List<String> selectSemesterOptions(CourseOfferingsState state) {
  final semesters = {
    for (final item in selectAllOfferings(state)) item.semester,
  }.toList()..sort();
  return List<String>.unmodifiable(semesters);
}
