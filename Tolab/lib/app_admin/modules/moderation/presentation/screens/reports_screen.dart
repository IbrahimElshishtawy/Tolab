import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../state/app_state.dart';
import '../../models/moderation_models.dart';
import '../../state/moderation_state.dart';
import '../widgets/moderation_filters_bar.dart';
import '../widgets/moderation_helpers.dart';
import '../widgets/moderation_preview_dialog.dart';
import '../widgets/moderation_table_card.dart';

class ModerationReportsScreen extends StatelessWidget {
  const ModerationReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ReportsViewModel>(
      converter: (store) {
        final state = store.state.moderationState;
        return _ReportsViewModel(
          page: selectReportsPage(store.state),
          query: state.reportsQuery,
          selectedIds: state.selectedReportIds,
          types: [
            'All',
            ...{
              for (final report in state.reports) report.contentType,
            },
          ],
        );
      },
      builder: (context, vm) {
        return Column(
          children: [
            ModerationFiltersBar(
              searchHint: 'Search reports, reasons, reporters, or linked content',
              searchValue: vm.query.searchQuery,
              onSearchChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(searchQuery: value, resetPage: true),
              ),
              statusOptions: const ['All', 'Pending', 'Flagged', 'Ignored', 'Removed', 'Suspended'],
              selectedStatus: vm.query.statusFilter,
              onStatusChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(statusFilter: value, resetPage: true),
              ),
              secondaryLabel: 'Type',
              secondaryOptions: vm.types,
              selectedSecondary: vm.query.secondaryFilter,
              onSecondaryChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(secondaryFilter: value, resetPage: true),
              ),
              dateOptions: const ['Any time', 'Today', 'Last 7 days', 'Last 30 days'],
              selectedDate: vm.query.dateFilter,
              onDateChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(dateFilter: value, resetPage: true),
              ),
              trailing: [
                if (vm.selectedIds.isNotEmpty)
                  PremiumButton(
                    label: 'Ignore ${vm.selectedIds.length}',
                    icon: Icons.do_disturb_alt_outlined,
                    isSecondary: true,
                    onPressed: () => dispatchModerationCommand(
                      context,
                      command: ModerationActionCommand(
                        actionType: ModerationActionType.ignoreReport,
                        targetType: 'report',
                        targetIds: vm.selectedIds.toList(growable: false),
                      ),
                    ),
                  ),
                if (vm.selectedIds.isNotEmpty)
                  PremiumButton(
                    label: 'Ban ${vm.selectedIds.length}',
                    icon: Icons.gpp_bad_outlined,
                    isDestructive: true,
                    onPressed: () => dispatchModerationCommand(
                      context,
                      command: ModerationActionCommand(
                        actionType: ModerationActionType.banUser,
                        targetType: 'report',
                        targetIds: vm.selectedIds.toList(growable: false),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ModerationTableCard<ModerationReport>(
                title: 'Reports register',
                subtitle:
                    'Link each report to its source content and resolve the right policy action.',
                items: vm.page.items,
                columns: [
                  ModerationTableColumn<ModerationReport>(
                    key: 'subject',
                    label: 'Linked content',
                    size: ColumnSize.L,
                    cellBuilder: (context, report) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          report.subjectTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          report.contentPreview,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ModerationTableColumn<ModerationReport>(
                    key: 'type',
                    label: 'Type',
                    sortable: true,
                    cellBuilder: (context, report) => Text(report.contentType),
                  ),
                  ModerationTableColumn<ModerationReport>(
                    key: 'reporter',
                    label: 'Reporter',
                    sortable: true,
                    cellBuilder: (context, report) => Text(report.reporterName),
                  ),
                  ModerationTableColumn<ModerationReport>(
                    key: 'status',
                    label: 'Status',
                    cellBuilder: (context, report) => StatusBadge(report.status.label),
                  ),
                  ModerationTableColumn<ModerationReport>(
                    key: 'createdAt',
                    label: 'Date',
                    sortable: true,
                    cellBuilder: (context, report) =>
                        Text(formatModerationDate(report.createdAt)),
                  ),
                  ModerationTableColumn<ModerationReport>(
                    key: 'actions',
                    label: 'Actions',
                    size: ColumnSize.S,
                    cellBuilder: (context, report) => IconButton(
                      onPressed: () => _openPreview(context, report),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                    ),
                  ),
                ],
                idOf: (report) => report.id,
                mobileTitleBuilder: (report) => report.subjectTitle,
                mobileSubtitleBuilder: (report) =>
                    '${report.contentType}  •  ${report.reason}',
                mobileBadgesBuilder: (context, report) => [
                  StatusBadge(report.status.label),
                  StatusBadge(report.groupName),
                ],
                mobileFooterBuilder: (context, report) => [
                  Text(
                    '${report.reporterName}  •  ${formatModerationDate(report.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                pageSlice: vm.page,
                selectedIds: vm.selectedIds,
                sortKey: vm.query.sortKey,
                ascending: vm.query.ascending,
                onSort: (key) => _updateQuery(
                  context,
                  vm.query.copyWith(
                    sortKey: key,
                    ascending: key == vm.query.sortKey ? !vm.query.ascending : false,
                  ),
                ),
                onRowTap: (report) => _openPreview(context, report),
                onToggleSelection: (itemId, selected) {
                  StoreProvider.of<AppState>(context).dispatch(
                    ModerationSelectionToggledAction(
                      section: ModerationSectionKey.reports,
                      itemId: itemId,
                      selected: selected,
                    ),
                  );
                },
                onToggleVisibleSelection: (selected) {
                  StoreProvider.of<AppState>(context).dispatch(
                    ModerationVisibleSelectionChangedAction(
                      section: ModerationSectionKey.reports,
                      visibleIds: vm.page.visibleIds,
                      selected: selected,
                    ),
                  );
                },
                onPageChanged: (page) =>
                    _updateQuery(context, vm.query.copyWith(page: page)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateQuery(BuildContext context, ModerationTableQuery query) {
    StoreProvider.of<AppState>(context).dispatch(
      ModerationQueryChangedAction(
        section: ModerationSectionKey.reports,
        query: query,
      ),
    );
  }

  Future<void> _openPreview(
    BuildContext context,
    ModerationReport report,
  ) async {
    await showModerationPreviewDialog(
      context: context,
      title: report.subjectTitle,
      subtitle: '${report.contentType} report in ${report.groupName}',
      status: report.status.label,
      content: report.contentPreview,
      metadata: [
        MapEntry('Reporter', report.reporterName),
        MapEntry('Reason', report.reason),
        MapEntry('Created', formatModerationDate(report.createdAt)),
      ],
      actions: [
        buildPreviewActionButton(
          label: 'Ignore',
          icon: Icons.do_disturb_alt_outlined,
          onPressed: () => dispatchModerationCommand(
            context,
            command: ModerationActionCommand(
              actionType: ModerationActionType.ignoreReport,
              targetType: 'report',
              targetIds: [report.id],
            ),
          ),
        ),
        buildPreviewActionButton(
          label: 'Warn',
          icon: Icons.warning_amber_rounded,
          onPressed: () => dispatchModerationCommand(
            context,
            command: ModerationActionCommand(
              actionType: ModerationActionType.warn,
              targetType: 'report',
              targetIds: [report.id],
            ),
          ),
        ),
        buildPreviewActionButton(
          label: 'Remove',
          icon: Icons.delete_outline_rounded,
          destructive: true,
          onPressed: () => dispatchModerationCommand(
            context,
            command: ModerationActionCommand(
              actionType: ModerationActionType.deleteContent,
              targetType: 'report',
              targetIds: [report.id],
            ),
          ),
        ),
        buildPreviewActionButton(
          label: 'Ban',
          icon: Icons.gpp_bad_outlined,
          destructive: true,
          onPressed: () => dispatchModerationCommand(
            context,
            command: ModerationActionCommand(
              actionType: ModerationActionType.banUser,
              targetType: 'report',
              targetIds: [report.id],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportsViewModel {
  const _ReportsViewModel({
    required this.page,
    required this.query,
    required this.selectedIds,
    required this.types,
  });

  final ModerationPageSlice<ModerationReport> page;
  final ModerationTableQuery query;
  final Set<String> selectedIds;
  final List<String> types;
}
