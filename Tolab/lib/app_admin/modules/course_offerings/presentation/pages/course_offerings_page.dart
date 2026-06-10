import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../../../app/localization/app_localizations.dart';
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
import '../models/course_offerings_view_model.dart';
import '../widgets/offering_card.dart';
import '../widgets/offering_filters.dart';
import '../widgets/offering_form.dart';
import '../widgets/offering_table.dart';
import '../widgets/offering_summary_card.dart';
import '../widgets/academic_delivery_panel.dart';

class CourseOfferingsPage extends StatelessWidget {
  const CourseOfferingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CourseOfferingsViewModel>(
      onInit: (store) => store.dispatch(const FetchCourseOfferingsAction()),
      converter: (store) => CourseOfferingsViewModel.fromStore(store),
      distinct: true,
      onDidChange: (previous, current) {
        if (current.feedbackMessage != null &&
            current.feedbackMessage != previous?.feedbackMessage &&
            context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.byValue(current.feedbackMessage!))));
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
                      title: context.l10n.byValue('Course Offerings'),
                      subtitle: context.l10n.byValue(
                          'Manage the live academic delivery layer across subjects, staff, sections, and capacity planning.'),
                      breadcrumbs: const ['Admin', 'Academic']
                          .map((b) => context.l10n.byValue(b))
                          .toList(),
                      actions: [
                        PremiumButton(
                          label: context.l10n.byValue('New offering'),
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
                        OfferingSummaryCard(
                          label: context.l10n.byValue('Filtered offerings'),
                          value: '${vm.metrics.total}',
                          accent: AppColors.primary,
                        ),
                        OfferingSummaryCard(
                          label: context.l10n.byValue('Active offerings'),
                          value: '${vm.metrics.active}',
                          accent: AppColors.secondary,
                        ),
                        OfferingSummaryCard(
                          label: context.l10n.byValue('Average fill rate'),
                          value:
                              '${(vm.metrics.averageFillRate * 100).round()}%',
                          accent: AppColors.warning,
                        ),
                        OfferingSummaryCard(
                          label: context.l10n.byValue('Seats remaining'),
                          value: '${vm.metrics.totalSeatsRemaining}',
                          accent: AppColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AcademicDeliveryPanel(offerings: vm.visibleOfferings),
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
                        onRetry: () => vm.store.dispatch(
                          const FetchCourseOfferingsAction(),
                        ),
                        isEmpty:
                            vm.filteredCount == 0 &&
                            vm.status == LoadStatus.success,
                        emptyTitle: context.l10n.byValue('No offerings match the current view'),
                        emptySubtitle: context.l10n.byValue(
                            'Adjust your search or filters to reveal more course offerings.'),
                        child: Column(
                          children: [
                            Expanded(
                              child: switch (AppBreakpoints.resolve(context)) {
                                DeviceScreenType.desktop => OfferingTable(
                                    offerings: vm.visibleOfferings,
                                    onView: (item) => context.push(
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
                                        onView: () => context.push(
                                          RoutePaths.courseOfferingDetails(
                                            item.id,
                                          ),
                                        ),
                                        onEdit: () => OfferingForm.show(
                                          context,
                                          initialOffering: item,
                                        ),
                                        onDelete: () => _confirmDelete(
                                          context,
                                          vm.store,
                                          item,
                                        ),
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
                                        onView: () => context.push(
                                          RoutePaths.courseOfferingDetails(
                                            item.id,
                                          ),
                                        ),
                                        onEdit: () => OfferingForm.show(
                                          context,
                                          initialOffering: item,
                                        ),
                                        onDelete: () => _confirmDelete(
                                          context,
                                          vm.store,
                                          item,
                                        ),
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
                                      ? '${context.l10n.byValue('Page')} ${vm.page}/${vm.totalPages}'
                                      : '${context.l10n.byValue('Showing')} ${vm.visibleOfferings.length} ${context.l10n.byValue('of')} ${vm.filteredCount} ${context.l10n.byValue('offerings')}';

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
                                        icon: const Icon(
                                          Icons.chevron_left_rounded,
                                        ),
                                      ),
                                      if (isDesktop && !compact)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.sm,
                                          ),
                                          child: Text(
                                            '${context.l10n.byValue('Page')} ${vm.page} / ${vm.totalPages}',
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
                                        icon: const Icon(
                                          Icons.chevron_right_rounded,
                                        ),
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
      title: context.l10n.byValue('Delete offering'),
      message:
          '${context.l10n.byValue('Delete')} ${offering.code} - ${context.l10n.byValue(offering.subjectName)}? ${context.l10n.byValue('This removes the current admin snapshot.')}',
    );
    if (!confirmed || !context.mounted) return;
    store.dispatch(DeleteCourseOfferingAction(offeringId: offering.id));
  }
}
