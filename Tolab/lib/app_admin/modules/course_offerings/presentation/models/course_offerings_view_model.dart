import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

import '../../../../shared/enums/load_status.dart';
import '../../../../state/app_state.dart';
import '../../models/course_offering_model.dart';
import '../../state/course_offerings_selectors.dart';

class CourseOfferingsViewModel {
  const CourseOfferingsViewModel({
    required this.store,
    required this.status,
    required this.mutationStatus,
    required this.filters,
    required this.pagination,
    required this.visibleOfferings,
    required this.filteredCount,
    required this.totalPages,
    required this.semesterOptions,
    required this.departments,
    required this.metrics,
    this.errorMessage,
    this.feedbackMessage,
  });

  final Store<AppState> store;
  final LoadStatus status;
  final LoadStatus mutationStatus;
  final CourseOfferingsFilters filters;
  final CourseOfferingsPagination pagination;
  final List<CourseOfferingModel> visibleOfferings;
  final int filteredCount;
  final int totalPages;
  final List<String> semesterOptions;
  final List<CourseOfferingLookupOption> departments;
  final CourseOfferingsDashboardMetrics metrics;
  final String? errorMessage;
  final String? feedbackMessage;

  int get page => pagination.page;

  factory CourseOfferingsViewModel.fromStore(Store<AppState> store) {
    final state = store.state.courseOfferingsState;
    final totalPages = selectFilteredTotalPages(state);
    final nextPage = state.pagination.page > totalPages
        ? totalPages
        : state.pagination.page;
    final pagination = state.pagination.copyWith(
      page: nextPage,
      totalPages: totalPages,
    );
    return CourseOfferingsViewModel(
      store: store,
      status: state.status,
      mutationStatus: state.mutationStatus,
      filters: state.filters,
      pagination: pagination,
      visibleOfferings: selectVisibleOfferings(
        state.copyWith(pagination: pagination),
      ),
      filteredCount: selectFilteredOfferings(state).length,
      totalPages: totalPages,
      semesterOptions: selectSemesterOptions(state),
      departments: state.departments,
      metrics: selectCourseOfferingsMetrics(state),
      errorMessage: state.errorMessage,
      feedbackMessage: state.feedbackMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CourseOfferingsViewModel &&
        other.status == status &&
        other.mutationStatus == mutationStatus &&
        other.filters.searchQuery == filters.searchQuery &&
        other.filters.semester == filters.semester &&
        other.filters.departmentId == filters.departmentId &&
        other.filters.status == filters.status &&
        other.page == page &&
        other.totalPages == totalPages &&
        other.filteredCount == filteredCount &&
        other.errorMessage == errorMessage &&
        other.feedbackMessage == feedbackMessage &&
        listEquals(
          other.visibleOfferings.map((item) => item.id).toList(),
          visibleOfferings.map((item) => item.id).toList(),
        );
  }

  @override
  int get hashCode => Object.hash(
    status,
    mutationStatus,
    filters.searchQuery,
    filters.semester,
    filters.departmentId,
    filters.status,
    page,
    totalPages,
    filteredCount,
    errorMessage,
    feedbackMessage,
  );
}
