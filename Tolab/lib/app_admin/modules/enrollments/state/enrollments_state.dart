import '../../../shared/enums/load_status.dart';
import '../models/enrollment_models.dart';

class EnrollmentsState {
  const EnrollmentsState({
    this.status = LoadStatus.initial,
    this.mutationStatus = LoadStatus.initial,
    this.items = const <EnrollmentRecord>[],
    this.filters = const EnrollmentsFilters(),
    this.sort = const EnrollmentsSort(),
    this.pagination = const EnrollmentsPagination(),
    this.lookups = const EnrollmentLookupBundle(),
    this.summary = const EnrollmentDashboardSummary(
      totalEnrollments: 0,
      enrolledCount: 0,
      pendingCount: 0,
      rejectedCount: 0,
      averageOccupancy: 0,
      courseSummary: <EnrollmentCourseSummary>[],
      sectionSummary: <EnrollmentSectionSummary>[],
      statusBreakdown: <EnrollmentStatusSlice>[
        EnrollmentStatusSlice(status: EnrollmentStatus.enrolled, count: 0),
        EnrollmentStatusSlice(status: EnrollmentStatus.pending, count: 0),
        EnrollmentStatusSlice(status: EnrollmentStatus.rejected, count: 0),
      ],
    ),
    this.selectedIds = const <String>{},
    this.bulkPreview,
    this.errorMessage,
    this.feedbackMessage,
    this.highlightedEnrollmentId,
  });

  final LoadStatus status;
  final LoadStatus mutationStatus;
  final List<EnrollmentRecord> items;
  final EnrollmentsFilters filters;
  final EnrollmentsSort sort;
  final EnrollmentsPagination pagination;
  final EnrollmentLookupBundle lookups;
  final EnrollmentDashboardSummary summary;
  final Set<String> selectedIds;
  final EnrollmentBulkPreview? bulkPreview;
  final String? errorMessage;
  final String? feedbackMessage;
  final String? highlightedEnrollmentId;

  EnrollmentsState copyWith({
    LoadStatus? status,
    LoadStatus? mutationStatus,
    List<EnrollmentRecord>? items,
    EnrollmentsFilters? filters,
    EnrollmentsSort? sort,
    EnrollmentsPagination? pagination,
    EnrollmentLookupBundle? lookups,
    EnrollmentDashboardSummary? summary,
    Set<String>? selectedIds,
    EnrollmentBulkPreview? bulkPreview,
    bool clearBulkPreview = false,
    String? errorMessage,
    bool clearError = false,
    String? feedbackMessage,
    bool clearFeedback = false,
    String? highlightedEnrollmentId,
    bool clearHighlight = false,
  }) {
    return EnrollmentsState(
      status: status ?? this.status,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      items: List<EnrollmentRecord>.unmodifiable(items ?? this.items),
      filters: filters ?? this.filters,
      sort: sort ?? this.sort,
      pagination: pagination ?? this.pagination,
      lookups: lookups ?? this.lookups,
      summary: summary ?? this.summary,
      selectedIds: Set<String>.unmodifiable(selectedIds ?? this.selectedIds),
      bulkPreview: clearBulkPreview ? null : bulkPreview ?? this.bulkPreview,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      feedbackMessage: clearFeedback
          ? null
          : feedbackMessage ?? this.feedbackMessage,
      highlightedEnrollmentId: clearHighlight
          ? null
          : highlightedEnrollmentId ?? this.highlightedEnrollmentId,
    );
  }
}

const initialEnrollmentsState = EnrollmentsState();
