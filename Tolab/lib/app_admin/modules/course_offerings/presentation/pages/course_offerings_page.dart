import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../shared/widgets/async_state_view.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../../state/app_state.dart';
import '../../models/course_offering_model.dart';
import '../../state/course_offerings_actions.dart';
import '../../state/course_offerings_selectors.dart';
import '../widgets/offering_card.dart';
import '../widgets/offering_filters.dart';
import '../widgets/offering_form.dart';
import '../widgets/offering_table.dart';

class CourseOfferingsPage extends StatelessWidget {
  const CourseOfferingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _CourseOfferingsViewModel>(
      onInit: (store) => store.dispatch(const FetchCourseOfferingsAction()),
      converter: (store) => _CourseOfferingsViewModel.fromStore(store),
      distinct: true,
      onDidChange: (previous, current) {
        if (current.feedbackMessage != null &&
            current.feedbackMessage != previous?.feedbackMessage &&
            context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(current.feedbackMessage!)));
          StoreProvider.of<AppState>(
            context,
          ).dispatch(const ResetCourseOfferingFeedbackAction());
        }
      },
      builder: (context, vm) {
        final isDesktop = AppBreakpoints.isDesktop(context);
        final isMobile = AppBreakpoints.isMobile(context);

        return LayoutBuilder(
          builder: (context, constraints) {
            final workspaceHeight = _workspaceHeight(
              constraints.maxHeight,
              isMobile: isMobile,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      title: 'Course Offerings',
                      subtitle:
                          'Manage the live academic delivery layer across subjects, staff, sections, and capacity planning.',
                      breadcrumbs: const ['Admin', 'Academic'],
                      actions: [
                        PremiumButton(
                          label: 'New offering',
                          icon: Icons.add_rounded,
                          onPressed: () => OfferingForm.show(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        _SummaryCard(
                          label: 'Filtered offerings',
                          value: '${vm.metrics.total}',
                          accent: AppColors.primary,
                        ),
                        _SummaryCard(
                          label: 'Active offerings',
                          value: '${vm.metrics.active}',
                          accent: AppColors.secondary,
                        ),
                        _SummaryCard(
                          label: 'Average fill rate',
                          value: '${(vm.metrics.averageFillRate * 100).round()}%',
                          accent: AppColors.warning,
                        ),
                        _SummaryCard(
                          label: 'Seats remaining',
                          value: '${vm.metrics.totalSeatsRemaining}',
                          accent: AppColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _AcademicDeliveryPanel(offerings: vm.visibleOfferings),
                    const SizedBox(height: AppSpacing.md),
                    OfferingFilters(
                      filters: vm.filters,
                      semesterOptions: vm.semesterOptions,
                      departments: vm.departments,
                      isMutating: vm.mutationStatus == LoadStatus.loading,
                      onSearchChanged: (value) => vm.store.dispatch(
                        CourseOfferingsFiltersChangedAction(
                          vm.filters.copyWith(searchQuery: value),
                        ),
                      ),
                      onSemesterChanged: (value) => vm.store.dispatch(
                        CourseOfferingsFiltersChangedAction(
                          value == null
                              ? vm.filters.copyWith(clearSemester: true)
                              : vm.filters.copyWith(semester: value),
                        ),
                      ),
                      onDepartmentChanged: (value) => vm.store.dispatch(
                        CourseOfferingsFiltersChangedAction(
                          value == null
                              ? vm.filters.copyWith(clearDepartmentId: true)
                              : vm.filters.copyWith(departmentId: value),
                        ),
                      ),
                      onStatusChanged: (value) => vm.store.dispatch(
                        CourseOfferingsFiltersChangedAction(
                          value == null
                              ? vm.filters.copyWith(clearStatus: true)
                              : vm.filters.copyWith(status: value),
                        ),
                      ),
                      onReset: () => vm.store.dispatch(
                        const CourseOfferingsFiltersChangedAction(
                          CourseOfferingsFilters(),
                        ),
                      ),
                      onCreate: () => OfferingForm.show(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: workspaceHeight,
                      child: AsyncStateView(
                        status: vm.status,
                        errorMessage: vm.errorMessage,
                        onRetry: () =>
                            vm.store.dispatch(const FetchCourseOfferingsAction()),
                        isEmpty:
                            vm.filteredCount == 0 &&
                            vm.status == LoadStatus.success,
                        emptyTitle: 'No offerings match the current view',
                        emptySubtitle:
                            'Adjust your search or filters to reveal more course offerings.',
                        child: Column(
                          children: [
                            Expanded(
                              child: switch (AppBreakpoints.resolve(context)) {
                                DeviceScreenType.desktop => OfferingTable(
                                  offerings: vm.visibleOfferings,
                                  onView: (item) => context.go(
                                    RoutePaths.courseOfferingDetails(item.id),
                                  ),
                                  onEdit: (item) => OfferingForm.show(
                                    context,
                                    initialOffering: item,
                                  ),
                                  onDelete: (item) =>
                                      _confirmDelete(context, vm.store, item),
                                ),
                                DeviceScreenType.tablet => GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: AppSpacing.md,
                                        mainAxisSpacing: AppSpacing.md,
                                        childAspectRatio: 1.25,
                                      ),
                                  itemCount: vm.visibleOfferings.length,
                                  itemBuilder: (context, index) {
                                    final item = vm.visibleOfferings[index];
                                    return OfferingCard(
                                      offering: item,
                                      onView: () => context.go(
                                        RoutePaths.courseOfferingDetails(item.id),
                                      ),
                                      onEdit: () => OfferingForm.show(
                                        context,
                                        initialOffering: item,
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(context, vm.store, item),
                                    );
                                  },
                                ),
                                DeviceScreenType.mobile => ListView.separated(
                                  itemCount: vm.visibleOfferings.length,
                                  separatorBuilder: (_, index) =>
                                      const SizedBox(height: AppSpacing.md),
                                  itemBuilder: (context, index) {
                                    final item = vm.visibleOfferings[index];
                                    return OfferingCard(
                                      offering: item,
                                      onView: () => context.go(
                                        RoutePaths.courseOfferingDetails(item.id),
                                      ),
                                      onEdit: () => OfferingForm.show(
                                        context,
                                        initialOffering: item,
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(context, vm.store, item),
                                    );
                                  },
                                ),
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppCard(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final compact = constraints.maxWidth < 540;
                                  final summaryText = isMobile
                                      ? 'Page ${vm.page}/${vm.totalPages}'
                                      : 'Showing ${vm.visibleOfferings.length} of ${vm.filteredCount} offerings';

                                  final pager = Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: vm.page <= 1
                                            ? null
                                            : () => vm.store.dispatch(
                                                CourseOfferingsPaginationChangedAction(
                                                  vm.pagination.copyWith(
                                                    page: vm.page - 1,
                                                  ),
                                                ),
                                              ),
                                        icon: const Icon(Icons.chevron_left_rounded),
                                      ),
                                      if (isDesktop && !compact)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.sm,
                                          ),
                                          child: Text(
                                            'Page ${vm.page} / ${vm.totalPages}',
                                          ),
                                        ),
                                      IconButton(
                                        onPressed: vm.page >= vm.totalPages
                                            ? null
                                            : () => vm.store.dispatch(
                                                CourseOfferingsPaginationChangedAction(
                                                  vm.pagination.copyWith(
                                                    page: vm.page + 1,
                                                  ),
                                                ),
                                              ),
                                        icon: const Icon(Icons.chevron_right_rounded),
                                      ),
                                    ],
                                  );

                                  return compact
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              summaryText,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.sm,
                                            ),
                                            pager,
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                summaryText,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                            ),
                                            pager,
                                          ],
                                        );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _workspaceHeight(double availableHeight, {required bool isMobile}) {
    final target = availableHeight * (isMobile ? 0.78 : 0.58);
    return target.clamp(420.0, 760.0).toDouble();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Store<AppState> store,
    CourseOfferingModel offering,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete offering',
      message:
          'Delete ${offering.code} - ${offering.subjectName}? This removes the current admin snapshot.',
    );
    if (!confirmed || !context.mounted) return;
    store.dispatch(DeleteCourseOfferingAction(offeringId: offering.id));
  }
}

class _AcademicDeliveryPanel extends StatelessWidget {
  const _AcademicDeliveryPanel({required this.offerings});

  final List<CourseOfferingModel> offerings;

  @override
  Widget build(BuildContext context) {
    final active = offerings
        .where((item) => item.status == CourseOfferingStatus.active)
        .length;
    final highDemand = offerings.where((item) => item.fillRate >= 0.85).length;
    final departments = offerings.map((item) => item.departmentName).toSet();
    final academicYears = offerings.map((item) => item.academicYear).toSet();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic delivery snapshot',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'A cleaner split for active delivery, demand pressure, and academic coverage across the current offerings view.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _InsightChip(
                label: '$active active now',
                color: AppColors.secondary,
              ),
              _InsightChip(
                label: '$highDemand high-demand sections',
                color: AppColors.warning,
              ),
              _InsightChip(
                label: '${departments.length} departments',
                color: AppColors.info,
              ),
              _InsightChip(
                label: academicYears.isEmpty
                    ? 'No academic year data'
                    : academicYears.join(' • '),
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 196,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 10,
              width: 56,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _CourseOfferingsViewModel {
  const _CourseOfferingsViewModel({
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

  factory _CourseOfferingsViewModel.fromStore(Store<AppState> store) {
    final state = store.state.courseOfferingsState;
    final totalPages = selectFilteredTotalPages(state);
    final nextPage = state.pagination.page > totalPages
        ? totalPages
        : state.pagination.page;
    final pagination = state.pagination.copyWith(
      page: nextPage,
      totalPages: totalPages,
    );
    return _CourseOfferingsViewModel(
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
    return other is _CourseOfferingsViewModel &&
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
