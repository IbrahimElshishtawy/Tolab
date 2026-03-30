import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../state/app_state.dart';
import '../models/enrollment_models.dart';
import '../state/enrollments_actions.dart';
import '../state/enrollments_selectors.dart';
import '../widgets/enrollment_bulk_upload_widget.dart';
import '../widgets/enrollment_empty_state.dart';
import '../widgets/enrollment_filter_widget.dart';
import '../widgets/enrollment_form_widget.dart';
import '../widgets/enrollment_skeletons.dart';
import '../widgets/enrollment_summary_dashboard.dart';
import '../widgets/enrollment_table_widget.dart';

class EnrollmentsScreen extends StatefulWidget {
  const EnrollmentsScreen({super.key});

  @override
  State<EnrollmentsScreen> createState() => _EnrollmentsScreenState();
}

class _EnrollmentsScreenState extends State<EnrollmentsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _EnrollmentsViewModel>(
      onInit: (store) => store.dispatch(const FetchEnrollmentsAction()),
      converter: _EnrollmentsViewModel.fromStore,
      distinct: true,
      onDidChange: (previous, current) {
        if (_searchController.text != current.filters.searchQuery) {
          _searchController.value = TextEditingValue(
            text: current.filters.searchQuery,
            selection: TextSelection.collapsed(
              offset: current.filters.searchQuery.length,
            ),
          );
        }
        if (previous?.feedbackMessage != current.feedbackMessage &&
            current.feedbackMessage != null &&
            mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(current.feedbackMessage!)));
          StoreProvider.of<AppState>(
            context,
          ).dispatch(const ResetEnrollmentFeedbackAction());
        }
      },
      builder: (context, vm) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Enrollments',
              subtitle:
                  'Premium enrollment control for manual registration, bulk import review, inline approvals, and section occupancy intelligence.',
              breadcrumbs: const ['Admin', 'Academic', 'Enrollments'],
              actions: [
                PremiumButton(
                  label: 'Bulk upload',
                  icon: Icons.upload_file_rounded,
                  isSecondary: true,
                  onPressed: () => _openBulkUpload(context, vm),
                ),
                PremiumButton(
                  label: 'Add enrollment',
                  icon: Icons.add_rounded,
                  onPressed: () => _openForm(context, vm),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (vm.status == LoadStatus.loading && vm.items.isEmpty)
              const Expanded(child: EnrollmentSkeletons())
            else
              Expanded(
                child: AsyncStateView(
                  status: vm.status,
                  errorMessage: vm.errorMessage,
                  onRetry: () => _fetch(context),
                  isEmpty: false,
                  child: ListView(
                    children: [
                      EnrollmentSummaryDashboard(summary: vm.summary),
                      const SizedBox(height: AppSpacing.lg),
                      EnrollmentFilterWidget(
                        searchController: _searchController,
                        filters: vm.filters,
                        sort: vm.sort,
                        lookups: vm.lookups,
                        onSearchChanged: (value) => _updateFilters(
                          context,
                          vm.filters.copyWith(searchQuery: value),
                        ),
                        onStatusChanged: (value) => _updateFilters(
                          context,
                          value == null
                              ? vm.filters.copyWith(clearStatus: true)
                              : vm.filters.copyWith(status: value),
                        ),
                        onCourseChanged: (value) => _updateFilters(
                          context,
                          value == null
                              ? vm.filters.copyWith(
                                  clearCourseId: true,
                                  clearSectionId: true,
                                )
                              : vm.filters.copyWith(
                                  courseId: value,
                                  clearSectionId: true,
                                ),
                        ),
                        onSectionChanged: (value) => _updateFilters(
                          context,
                          value == null
                              ? vm.filters.copyWith(clearSectionId: true)
                              : vm.filters.copyWith(sectionId: value),
                        ),
                        onSemesterChanged: (value) => _updateFilters(
                          context,
                          value == null
                              ? vm.filters.copyWith(clearSemester: true)
                              : vm.filters.copyWith(semester: value),
                        ),
                        onYearChanged: (value) => _updateFilters(
                          context,
                          value == null
                              ? vm.filters.copyWith(clearAcademicYear: true)
                              : vm.filters.copyWith(academicYear: value),
                        ),
                        onStaffChanged: (value) => _updateFilters(
                          context,
                          value == null
                              ? vm.filters.copyWith(clearStaffId: true)
                              : vm.filters.copyWith(staffId: value),
                        ),
                        onSortFieldChanged: (value) => _updateSort(
                          context,
                          vm.sort.copyWith(field: value),
                        ),
                        onSortDirectionChanged: (value) => _updateSort(
                          context,
                          vm.sort.copyWith(ascending: value),
                        ),
                        onClearFilters: () {
                          _searchController.clear();
                          _updateFilters(context, const EnrollmentsFilters());
                        },
                        onCreateEnrollment: () => _openForm(context, vm),
                        onBulkUpload: () => _openBulkUpload(context, vm),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (vm.items.isEmpty)
                        SizedBox(
                          height: 360,
                          child: EnrollmentEmptyState(
                            onCreate: () => _openForm(context, vm),
                            onBulkUpload: () => _openBulkUpload(context, vm),
                          ),
                        )
                      else
                        EnrollmentTableWidget(
                          items: vm.items,
                          pagination: vm.pagination,
                          highlightedEnrollmentId: vm.highlightedEnrollmentId,
                          onEdit: (record) =>
                              _openForm(context, vm, record: record),
                          onDelete: (record) =>
                              _deleteEnrollment(context, record),
                          onStatusChanged: (record, status) =>
                              _updateEnrollmentStatus(context, record, status),
                          onPageChanged: (page) => _updatePagination(
                            context,
                            vm.pagination.copyWith(page: page),
                          ),
                          onPerPageChanged: (perPage) => _updatePagination(
                            context,
                            vm.pagination.copyWith(page: 1, perPage: perPage),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _fetch(BuildContext context, {bool silent = false}) {
    StoreProvider.of<AppState>(
      context,
    ).dispatch(FetchEnrollmentsAction(silent: silent));
  }

  void _updateFilters(BuildContext context, EnrollmentsFilters filters) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(EnrollmentsFiltersChangedAction(filters));
    store.dispatch(const FetchEnrollmentsAction(silent: true));
  }

  void _updateSort(BuildContext context, EnrollmentsSort sort) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(EnrollmentsSortChangedAction(sort));
    store.dispatch(const FetchEnrollmentsAction(silent: true));
  }

  void _updatePagination(
    BuildContext context,
    EnrollmentsPagination pagination,
  ) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(EnrollmentsPaginationChangedAction(pagination));
    store.dispatch(const FetchEnrollmentsAction(silent: true));
  }

  Future<void> _openForm(
    BuildContext context,
    _EnrollmentsViewModel vm, {
    EnrollmentRecord? record,
  }) async {
    final content = Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: EnrollmentFormWidget(
        lookups: vm.lookups,
        initialRecord: record,
        submitLabel: record == null ? 'Create enrollment' : 'Save changes',
        onCancel: () => Navigator.of(context).maybePop(),
        onSubmit: (payload) {
          final store = StoreProvider.of<AppState>(context);
          if (record == null) {
            store.dispatch(
              CreateEnrollmentAction(
                payload: payload,
                onSuccess: () => Navigator.of(context).maybePop(),
              ),
            );
          } else {
            store.dispatch(
              UpdateEnrollmentAction(
                enrollmentId: record.id,
                payload: payload,
                onSuccess: () => Navigator.of(context).maybePop(),
              ),
            );
          }
        },
      ),
    );
    await _showAdaptiveEditor(context, content);
  }

  Future<void> _openBulkUpload(
    BuildContext context,
    _EnrollmentsViewModel vm,
  ) async {
    final store = StoreProvider.of<AppState>(context);
    final content = Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: EnrollmentBulkUploadWidget(
        lookups: vm.lookups,
        preview: vm.bulkPreview,
        onPreviewPrepared: (preview) =>
            store.dispatch(EnrollmentBulkPreviewPreparedAction(preview)),
        onSubmit: (payloads) {
          store.dispatch(
            SubmitBulkEnrollmentsAction(
              payloads: payloads,
              onSuccess: () {
                store.dispatch(const ClearEnrollmentBulkPreviewAction());
                Navigator.of(context).maybePop();
              },
            ),
          );
        },
        onClose: () => Navigator.of(context).maybePop(),
      ),
    );
    await _showAdaptiveEditor(context, content, maxWidth: 980);
  }

  Future<void> _deleteEnrollment(
    BuildContext context,
    EnrollmentRecord record,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete enrollment',
      message:
          'Remove ${record.studentName} from ${record.courseName} (${record.sectionName})?',
    );
    if (!confirmed || !context.mounted) return;
    StoreProvider.of<AppState>(
      context,
    ).dispatch(DeleteEnrollmentAction(enrollmentId: record.id));
  }

  void _updateEnrollmentStatus(
    BuildContext context,
    EnrollmentRecord record,
    EnrollmentStatus status,
  ) {
    StoreProvider.of<AppState>(
      context,
    ).dispatch(UpdateEnrollmentStatusAction(record: record, status: status));
  }

  Future<void> _showAdaptiveEditor(
    BuildContext context,
    Widget child, {
    double maxWidth = 900,
  }) async {
    if (AppBreakpoints.isMobile(context)) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => child,
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 760),
            child: child,
          ),
        );
      },
    );
  }
}

class _EnrollmentsViewModel {
  const _EnrollmentsViewModel({
    required this.status,
    required this.mutationStatus,
    required this.items,
    required this.filters,
    required this.sort,
    required this.pagination,
    required this.lookups,
    required this.summary,
    required this.bulkPreview,
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
  final EnrollmentBulkPreview? bulkPreview;
  final String? errorMessage;
  final String? feedbackMessage;
  final String? highlightedEnrollmentId;

  factory _EnrollmentsViewModel.fromStore(Store<AppState> store) {
    final state = enrollmentsStateOf(store.state);
    return _EnrollmentsViewModel(
      status: state.status,
      mutationStatus: state.mutationStatus,
      items: selectEnrollmentItems(state),
      filters: state.filters,
      sort: state.sort,
      pagination: state.pagination,
      lookups: selectEnrollmentLookups(state),
      summary: selectEnrollmentSummary(state),
      bulkPreview: state.bulkPreview,
      errorMessage: state.errorMessage,
      feedbackMessage: state.feedbackMessage,
      highlightedEnrollmentId: state.highlightedEnrollmentId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _EnrollmentsViewModel &&
        other.status == status &&
        other.mutationStatus == mutationStatus &&
        listEquals(other.items, items) &&
        other.filters == filters &&
        other.sort == sort &&
        other.pagination == pagination &&
        listEquals(other.lookups.offerings, lookups.offerings) &&
        listEquals(other.lookups.students, lookups.students) &&
        other.summary.totalEnrollments == summary.totalEnrollments &&
        other.summary.pendingCount == summary.pendingCount &&
        other.summary.rejectedCount == summary.rejectedCount &&
        other.errorMessage == errorMessage &&
        other.feedbackMessage == feedbackMessage &&
        other.highlightedEnrollmentId == highlightedEnrollmentId &&
        other.bulkPreview?.fileName == bulkPreview?.fileName &&
        other.bulkPreview?.rows.length == bulkPreview?.rows.length;
  }

  @override
  int get hashCode => Object.hash(
    status,
    mutationStatus,
    items.length,
    filters,
    sort,
    pagination,
    lookups.offerings.length,
    lookups.students.length,
    summary.totalEnrollments,
    summary.pendingCount,
    summary.rejectedCount,
    errorMessage,
    feedbackMessage,
    highlightedEnrollmentId,
    bulkPreview?.fileName,
    bulkPreview?.rows.length,
  );
}
