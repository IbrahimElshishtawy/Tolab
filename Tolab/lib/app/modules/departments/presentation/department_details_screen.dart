import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../state/app_state.dart';
import '../models/department_models.dart';
import '../state/departments_selectors.dart';
import '../state/departments_state.dart';
import 'forms/department_form_sheet.dart';
import 'widgets/department_overview_tab.dart';
import 'widgets/department_primitives.dart';
import 'widgets/department_schedule_tab.dart';
import 'widgets/department_staff_tab.dart';
import 'widgets/department_students_tab.dart';
import 'widgets/department_subjects_tab.dart';

class DepartmentDetailsScreen extends StatelessWidget {
  const DepartmentDetailsScreen({super.key, required this.departmentId});

  final String departmentId;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DepartmentDetailsViewModel>(
      onInit: (store) {
        store.dispatch(const LoadDepartmentsAction());
        store.dispatch(SelectDepartmentAction(departmentId));
      },
      onDidChange: (previous, current) {
        if (current.department == null &&
            current.status == LoadStatus.success &&
            context.mounted) {
          context.go(RoutePaths.departments);
        }
      },
      converter: (store) =>
          _DepartmentDetailsViewModel.fromStore(store, departmentId),
      distinct: true,
      builder: (context, vm) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go(RoutePaths.departments),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Department details',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: AsyncStateView(
                status: vm.status,
                errorMessage: vm.errorMessage,
                onRetry: () => StoreProvider.of<AppState>(
                  context,
                ).dispatch(const LoadDepartmentsAction()),
                isEmpty:
                    vm.department == null && vm.status == LoadStatus.success,
                emptyTitle: 'Department not found',
                emptySubtitle:
                    'The requested department could not be resolved from the current workspace snapshot.',
                child: vm.department == null
                    ? const SizedBox.shrink()
                    : _DepartmentDetailsBody(
                        department: vm.department!,
                        activeTab: vm.activeTab,
                        faculties: vm.faculties,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DepartmentDetailsBody extends StatelessWidget {
  const _DepartmentDetailsBody({
    required this.department,
    required this.activeTab,
    required this.faculties,
  });

  final DepartmentRecord department;
  final DepartmentDetailTab activeTab;
  final List<String> faculties;

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    return ListView(
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: department.coverImageUrl,
                      height: isDesktop ? 240 : 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        height: isDesktop ? 240 : 200,
                        color: AppColors.primarySoft,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.06),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            DepartmentStatusPill(label: department.statusLabel),
                            DepartmentStatusPill(label: department.faculty),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          department.name,
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${department.code} • Led by ${department.headName}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.86),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        PremiumButton(
                          label: 'Edit department',
                          icon: Icons.edit_outlined,
                          onPressed:
                              department.permissions.allows('edit_department')
                              ? () => DepartmentFormSheet.show(
                                  context,
                                  initialDepartment: department,
                                  faculties: faculties,
                                )
                              : null,
                        ),
                        PremiumButton(
                          label: department.isActive
                              ? 'Deactivate'
                              : 'Activate',
                          icon: department.isActive
                              ? Icons.pause_circle_outline_rounded
                              : Icons.play_circle_outline_rounded,
                          isSecondary: true,
                          onPressed: () =>
                              StoreProvider.of<AppState>(context).dispatch(
                                ToggleDepartmentActivationRequestedAction(
                                  departmentIds: {department.id},
                                  isActive: !department.isActive,
                                ),
                              ),
                        ),
                        PremiumButton(
                          label: 'Archive',
                          icon: Icons.archive_outlined,
                          isSecondary: true,
                          onPressed:
                              department.permissions.allows('delete_department')
                              ? () => StoreProvider.of<AppState>(context)
                                    .dispatch(
                                      ArchiveDepartmentsRequestedAction({
                                        department.id,
                                      }),
                                    )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final tab in DepartmentDetailTab.values)
                          DepartmentChip(
                            label: _tabLabel(tab),
                            selected: activeTab == tab,
                            onTap: () => StoreProvider.of<AppState>(
                              context,
                            ).dispatch(DepartmentTabChangedAction(tab)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: isDesktop ? 980 : 760,
          child: switch (activeTab) {
            DepartmentDetailTab.overview => DepartmentOverviewTab(
              department: department,
            ),
            DepartmentDetailTab.students => DepartmentStudentsTab(
              students: department.students,
            ),
            DepartmentDetailTab.staff => DepartmentStaffTab(
              staff: department.staff,
            ),
            DepartmentDetailTab.subjects => DepartmentSubjectsTab(
              subjects: department.subjects,
            ),
            DepartmentDetailTab.schedule => DepartmentScheduleTab(
              offerings: department.courseOfferings,
              schedulePreview: department.schedulePreview,
            ),
          },
        ),
      ],
    );
  }

  String _tabLabel(DepartmentDetailTab tab) => switch (tab) {
    DepartmentDetailTab.overview => 'Overview',
    DepartmentDetailTab.students => 'Students',
    DepartmentDetailTab.staff => 'Staff',
    DepartmentDetailTab.subjects => 'Subjects',
    DepartmentDetailTab.schedule => 'Schedule',
  };
}

class _DepartmentDetailsViewModel {
  const _DepartmentDetailsViewModel({
    required this.status,
    required this.activeTab,
    required this.faculties,
    this.department,
    this.errorMessage,
  });

  final LoadStatus status;
  final DepartmentRecord? department;
  final DepartmentDetailTab activeTab;
  final List<String> faculties;
  final String? errorMessage;

  factory _DepartmentDetailsViewModel.fromStore(
    Store<AppState> store,
    String departmentId,
  ) {
    final state = store.state.departmentsState;
    final selected = state.items.where(
      (department) => department.id == departmentId,
    );
    return _DepartmentDetailsViewModel(
      status: state.status,
      department: selected.isNotEmpty
          ? selected.first
          : selectSelectedDepartment(state),
      activeTab: state.activeTab,
      faculties: selectDepartmentFacultyOptions(state),
      errorMessage: state.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _DepartmentDetailsViewModel &&
        other.status == status &&
        other.department == department &&
        other.activeTab == activeTab &&
        other.errorMessage == errorMessage &&
        other.faculties.length == faculties.length;
  }

  @override
  int get hashCode => Object.hash(
    status,
    department,
    activeTab,
    errorMessage,
    faculties.length,
  );
}
