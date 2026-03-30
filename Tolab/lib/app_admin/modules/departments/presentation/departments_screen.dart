import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../state/app_state.dart';
import '../models/department_models.dart';
import '../state/departments_selectors.dart';
import '../state/departments_state.dart';
import 'forms/department_form_sheet.dart';
import 'widgets/department_bulk_action_bar.dart';
import 'widgets/department_loading_skeleton.dart';
import 'widgets/department_primitives.dart';
import 'widgets/departments_mobile_cards.dart';
import 'widgets/departments_summary_strip.dart';
import 'widgets/departments_table_card.dart';
import 'widgets/departments_toolbar.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
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
    return StoreConnector<AppState, _DepartmentsViewModel>(
      onInit: (store) => store.dispatch(const LoadDepartmentsAction()),
      converter: (store) => _DepartmentsViewModel.fromStore(store),
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
        if (previous?.mutationMessage != current.mutationMessage &&
            current.mutationMessage != null &&
            current.mutationMessage!.isNotEmpty &&
            mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(current.mutationMessage!)));
          StoreProvider.of<AppState>(
            context,
          ).dispatch(const ResetDepartmentMutationAction());
        }
      },
      builder: (context, vm) {
        final isMobile = AppBreakpoints.isMobile(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Departments',
              subtitle:
                  'Premium academic administration for structure, staffing, student distribution, and schedule-led performance.',
              breadcrumbs: ['Admin', 'Academic', 'Departments'],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (vm.status == LoadStatus.loading && vm.items.isEmpty)
              const Expanded(child: DepartmentLoadingSkeleton())
            else
              Expanded(
                child: AsyncStateView(
                  status: vm.status,
                  errorMessage: vm.errorMessage,
                  onRetry: () => StoreProvider.of<AppState>(
                    context,
                  ).dispatch(const LoadDepartmentsAction()),
                  isEmpty: vm.filteredDepartments.isEmpty,
                  emptyTitle: 'No departments match these filters',
                  emptySubtitle:
                      'Clear one or more filters to restore the management surface.',
                  child: ListView(
                    children: [
                      DepartmentsSummaryStrip(metrics: vm.summary),
                      const SizedBox(height: AppSpacing.lg),
                      DepartmentsToolbar(
                        searchController: _searchController,
                        filters: vm.filters,
                        sort: vm.sort,
                        faculties: vm.faculties,
                        canCreateDepartment: vm.canCreateDepartment,
                        onSearchChanged: (value) => _updateFilters(
                          context,
                          vm.filters.copyWith(searchQuery: value),
                        ),
                        onStatusChanged: (value) => _updateFilters(
                          context,
                          vm.filters.copyWith(status: value),
                        ),
                        onFacultyChanged: (value) => _updateFilters(
                          context,
                          value == null
                              ? vm.filters.copyWith(clearFaculty: true)
                              : vm.filters.copyWith(faculty: value),
                        ),
                        onDensityChanged: (value) => _updateFilters(
                          context,
                          vm.filters.copyWith(density: value),
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
                          _updateFilters(context, const DepartmentFilters());
                        },
                        onCreateDepartment: () => DepartmentFormSheet.show(
                          context,
                          faculties: vm.faculties,
                        ),
                      ),
                      if (vm.selectedIds.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        DepartmentBulkActionBar(
                          count: vm.selectedIds.length,
                          onActivate: () =>
                              _toggleActivation(context, vm.selectedIds, true),
                          onDeactivate: () =>
                              _toggleActivation(context, vm.selectedIds, false),
                          onArchive: () =>
                              _archiveDepartments(context, vm.selectedIds),
                          onClear: () => StoreProvider.of<AppState>(
                            context,
                          ).dispatch(const DepartmentSelectionClearedAction()),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      if (isMobile)
                        SizedBox(
                          height: 680,
                          child: DepartmentsMobileCards(
                            departments: vm.visibleDepartments,
                            selectedIds: vm.selectedIds,
                            onToggleSelection: (value) =>
                                StoreProvider.of<AppState>(context).dispatch(
                                  DepartmentSelectionToggledAction(
                                    departmentId: value.$1,
                                    selected: value.$2,
                                  ),
                                ),
                            onOpenDepartment: (department) =>
                                _openDepartment(context, department),
                            onEditDepartment: (department) =>
                                DepartmentFormSheet.show(
                                  context,
                                  initialDepartment: department,
                                  faculties: vm.faculties,
                                ),
                            onToggleActivation: (department, isActive) =>
                                _toggleActivation(context, {
                                  department.id,
                                }, isActive),
                            onArchiveDepartment: (department) =>
                                _archiveDepartments(context, {department.id}),
                          ),
                        )
                      else
                        DepartmentsTableCard(
                          departments: vm.visibleDepartments,
                          selectedIds: vm.selectedIds,
                          areAllVisibleSelected: vm.areAllVisibleSelected,
                          currentPage: vm.pagination.page,
                          totalPages: vm.totalPages,
                          perPage: vm.pagination.perPage,
                          onToggleSelection: (value) =>
                              StoreProvider.of<AppState>(context).dispatch(
                                DepartmentSelectionToggledAction(
                                  departmentId: value.$1,
                                  selected: value.$2,
                                ),
                              ),
                          onToggleSelectAll: (selected) =>
                              StoreProvider.of<AppState>(context).dispatch(
                                DepartmentVisibleSelectionChangedAction(
                                  visibleIds: vm.visibleDepartments
                                      .map((department) => department.id)
                                      .toSet(),
                                  selected: selected,
                                ),
                              ),
                          onOpenDepartment: (department) =>
                              _openDepartment(context, department),
                          onEditDepartment: (department) =>
                              DepartmentFormSheet.show(
                                context,
                                initialDepartment: department,
                                faculties: vm.faculties,
                              ),
                          onToggleActivation: (department, isActive) =>
                              _toggleActivation(context, {
                                department.id,
                              }, isActive),
                          onArchiveDepartment: (department) =>
                              _archiveDepartments(context, {department.id}),
                          onPageChanged: (page) => _updatePagination(
                            context,
                            vm.pagination.copyWith(page: page),
                          ),
                          onPerPageChanged: (perPage) => _updatePagination(
                            context,
                            vm.pagination.copyWith(page: 1, perPage: perPage),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      _InsightCard(summary: vm.summary),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _updateFilters(BuildContext context, DepartmentFilters filters) {
    StoreProvider.of<AppState>(
      context,
    ).dispatch(DepartmentFiltersChangedAction(filters));
  }

  void _updateSort(BuildContext context, DepartmentsSort sort) {
    StoreProvider.of<AppState>(
      context,
    ).dispatch(DepartmentSortChangedAction(sort));
  }

  void _updatePagination(
    BuildContext context,
    DepartmentsPagination pagination,
  ) {
    StoreProvider.of<AppState>(
      context,
    ).dispatch(DepartmentPaginationChangedAction(pagination));
  }

  void _openDepartment(BuildContext context, DepartmentRecord department) {
    StoreProvider.of<AppState>(
      context,
    ).dispatch(SelectDepartmentAction(department.id));
    context.go(RoutePaths.departmentDetails(department.id));
  }

  void _toggleActivation(
    BuildContext context,
    Set<String> departmentIds,
    bool isActive,
  ) {
    StoreProvider.of<AppState>(context).dispatch(
      ToggleDepartmentActivationRequestedAction(
        departmentIds: departmentIds,
        isActive: isActive,
      ),
    );
  }

  void _archiveDepartments(BuildContext context, Set<String> departmentIds) {
    StoreProvider.of<AppState>(
      context,
    ).dispatch(ArchiveDepartmentsRequestedAction(departmentIds));
  }
}

class _DepartmentsViewModel {
  const _DepartmentsViewModel({
    required this.status,
    required this.items,
    required this.filteredDepartments,
    required this.visibleDepartments,
    required this.summary,
    required this.filters,
    required this.sort,
    required this.pagination,
    required this.totalPages,
    required this.selectedIds,
    required this.faculties,
    required this.canCreateDepartment,
    required this.areAllVisibleSelected,
    this.errorMessage,
    this.mutationMessage,
  });

  final LoadStatus status;
  final List<DepartmentRecord> items;
  final List<DepartmentRecord> filteredDepartments;
  final List<DepartmentRecord> visibleDepartments;
  final DepartmentsSummaryMetrics summary;
  final DepartmentFilters filters;
  final DepartmentsSort sort;
  final DepartmentsPagination pagination;
  final int totalPages;
  final Set<String> selectedIds;
  final List<String> faculties;
  final bool canCreateDepartment;
  final bool areAllVisibleSelected;
  final String? errorMessage;
  final String? mutationMessage;

  factory _DepartmentsViewModel.fromStore(Store<AppState> store) {
    final state = store.state.departmentsState;
    return _DepartmentsViewModel(
      status: state.status,
      items: state.items,
      filteredDepartments: selectFilteredDepartments(state),
      visibleDepartments: selectVisibleDepartments(state),
      summary: selectDepartmentsSummary(state),
      filters: state.filters,
      sort: state.sort,
      pagination: state.pagination,
      totalPages: selectTotalPages(state),
      selectedIds: state.selectedIds,
      faculties: selectDepartmentFacultyOptions(state),
      canCreateDepartment: selectCanCreateDepartment(state),
      areAllVisibleSelected: selectAreAllVisibleDepartmentsSelected(state),
      errorMessage: state.errorMessage,
      mutationMessage: state.mutationMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _DepartmentsViewModel &&
        other.status == status &&
        listEquals(other.items, items) &&
        listEquals(other.filteredDepartments, filteredDepartments) &&
        listEquals(other.visibleDepartments, visibleDepartments) &&
        other.summary.departmentsCount == summary.departmentsCount &&
        other.summary.studentsCount == summary.studentsCount &&
        other.summary.staffCount == summary.staffCount &&
        other.summary.averageSuccessRate == summary.averageSuccessRate &&
        other.filters == filters &&
        other.sort == sort &&
        other.pagination.page == pagination.page &&
        other.pagination.perPage == pagination.perPage &&
        other.totalPages == totalPages &&
        setEquals(other.selectedIds, selectedIds) &&
        listEquals(other.faculties, faculties) &&
        other.canCreateDepartment == canCreateDepartment &&
        other.areAllVisibleSelected == areAllVisibleSelected &&
        other.errorMessage == errorMessage &&
        other.mutationMessage == mutationMessage;
  }

  @override
  int get hashCode => Object.hash(
    status,
    items.length,
    filteredDepartments.length,
    visibleDepartments.length,
    summary.departmentsCount,
    summary.studentsCount,
    summary.staffCount,
    summary.averageSuccessRate,
    filters,
    sort,
    pagination.page,
    pagination.perPage,
    totalPages,
    selectedIds.length,
    faculties.length,
    canCreateDepartment,
    areAllVisibleSelected,
    errorMessage,
    mutationMessage,
  );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.summary});

  final DepartmentsSummaryMetrics summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.md,
        children: [
          _InsightItem(
            title: 'Operational signal',
            body:
                '${summary.activeDepartmentsCount}/${summary.departmentsCount} departments are currently active.',
          ),
          _InsightItem(
            title: 'Student density',
            body:
                '${formatCompactNumber(summary.studentsCount)} students are currently distributed across the department surface.',
          ),
          _InsightItem(
            title: 'Course load',
            body:
                '${summary.activeCoursesCount} live offerings are linked to active departments right now.',
          ),
        ],
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  const _InsightItem({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
