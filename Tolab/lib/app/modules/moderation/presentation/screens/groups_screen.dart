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

class ModerationGroupsScreen extends StatelessWidget {
  const ModerationGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _GroupsViewModel>(
      converter: (store) {
        final state = store.state.moderationState;
        return _GroupsViewModel(
          page: selectGroupsPage(store.state),
          query: state.groupsQuery,
          selectedIds: state.selectedGroupIds,
          categories: [
            'All',
            ...{
              for (final group in state.groups) group.category,
            },
          ],
          moderators: state.moderators,
        );
      },
      builder: (context, vm) {
        return Column(
          children: [
            ModerationFiltersBar(
              searchHint: 'Search groups, categories, moderators',
              searchValue: vm.query.searchQuery,
              onSearchChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(searchQuery: value, resetPage: true),
              ),
              statusOptions: const ['All', 'Active', 'Restricted', 'Pending'],
              selectedStatus: vm.query.statusFilter,
              onStatusChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(statusFilter: value, resetPage: true),
              ),
              secondaryLabel: 'Category',
              secondaryOptions: vm.categories,
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
                    label: 'Restrict ${vm.selectedIds.length}',
                    icon: Icons.lock_outline_rounded,
                    isSecondary: true,
                    onPressed: () async {
                      final confirmed = await confirmModerationAction(
                        context: context,
                        actionType: ModerationActionType.suspendUser,
                        subject: '${vm.selectedIds.length} groups',
                      );
                      if (!confirmed || !context.mounted) return;
                      dispatchModerationCommand(
                        context,
                        command: ModerationActionCommand(
                          actionType: ModerationActionType.suspendUser,
                          targetType: 'group',
                          targetIds: vm.selectedIds.toList(growable: false),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ModerationTableCard<ModerationGroup>(
                title: 'Groups directory',
                subtitle:
                    'Review community health, moderator coverage, and flagged activity trends.',
                items: vm.page.items,
                columns: [
                  ModerationTableColumn<ModerationGroup>(
                    key: 'name',
                    label: 'Group',
                    sortable: true,
                    size: ColumnSize.L,
                    cellBuilder: (context, group) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(group.name, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(group.description, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  ModerationTableColumn<ModerationGroup>(
                    key: 'category',
                    label: 'Category',
                    cellBuilder: (context, group) => Text(group.category),
                  ),
                  ModerationTableColumn<ModerationGroup>(
                    key: 'members',
                    label: 'Members',
                    sortable: true,
                    cellBuilder: (context, group) => Text(
                      '${group.memberCount}  •  ${group.moderatorsCount} moderators',
                    ),
                  ),
                  ModerationTableColumn<ModerationGroup>(
                    key: 'reports',
                    label: 'Moderation',
                    sortable: true,
                    cellBuilder: (context, group) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(group.status.label),
                        const SizedBox(width: AppSpacing.sm),
                        Text('${group.flaggedPostsCount} flagged'),
                      ],
                    ),
                  ),
                  ModerationTableColumn<ModerationGroup>(
                    key: 'lastActivityAt',
                    label: 'Last activity',
                    sortable: true,
                    cellBuilder: (context, group) => Text(
                      formatModerationDate(group.lastActivityAt),
                    ),
                  ),
                  ModerationTableColumn<ModerationGroup>(
                    key: 'actions',
                    label: 'Actions',
                    size: ColumnSize.S,
                    cellBuilder: (context, group) => IconButton(
                      onPressed: () => _openPreview(context, group, vm.moderators),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                    ),
                  ),
                ],
                idOf: (group) => group.id,
                mobileTitleBuilder: (group) => group.name,
                mobileSubtitleBuilder: (group) =>
                    '${group.category}  •  ${group.memberCount} members',
                mobileBadgesBuilder: (context, group) => [
                  StatusBadge(group.status.label),
                  StatusBadge('${group.flaggedPostsCount} flagged'),
                ],
                mobileFooterBuilder: (context, group) => [
                  Text(
                    'Last activity ${formatModerationDate(group.lastActivityAt)}',
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
                onRowTap: (group) => _openPreview(context, group, vm.moderators),
                onToggleSelection: (itemId, selected) {
                  StoreProvider.of<AppState>(context).dispatch(
                    ModerationSelectionToggledAction(
                      section: ModerationSectionKey.groups,
                      itemId: itemId,
                      selected: selected,
                    ),
                  );
                },
                onToggleVisibleSelection: (selected) {
                  StoreProvider.of<AppState>(context).dispatch(
                    ModerationVisibleSelectionChangedAction(
                      section: ModerationSectionKey.groups,
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
        section: ModerationSectionKey.groups,
        query: query,
      ),
    );
  }

  Future<void> _openPreview(
    BuildContext context,
    ModerationGroup group,
    List<ModerationModeratorAccount> moderators,
  ) async {
    await showModerationPreviewDialog(
      context: context,
      title: group.name,
      subtitle: group.description,
      status: group.status.label,
      content:
          'Members: ${group.memberPreview.join(', ')}\n\nFlagged posts this period: ${group.flaggedPostsCount}\nModerator coverage: ${group.moderatorsCount}',
      metadata: [
        MapEntry('Category', group.category),
        MapEntry('Members', group.memberCount.toString()),
        MapEntry('Last activity', formatModerationDate(group.lastActivityAt)),
      ],
      actions: [
        buildPreviewActionButton(
          label: 'Members',
          icon: Icons.group_outlined,
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('${group.name} members'),
                content: Text(group.memberPreview.join('\n')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
        buildPreviewActionButton(
          label: 'Assign',
          icon: Icons.admin_panel_settings_outlined,
          onPressed: () async {
            final selectedIds = await showAssignModeratorsDialog(
              context: context,
              groupName: group.name,
              moderators: moderators,
              selectedIds: group.moderatorIds,
            );
            if (selectedIds == null || !context.mounted) return;
            dispatchModerationCommand(
              context,
              command: ModerationActionCommand(
                actionType: ModerationActionType.assignModerators,
                targetType: 'group',
                targetIds: [group.id],
                userIds: selectedIds,
              ),
            );
          },
        ),
        buildPreviewActionButton(
          label: group.status == ModerationStatus.restricted
              ? 'Activate'
              : 'Restrict',
          icon: Icons.lock_outline_rounded,
          onPressed: () {
            dispatchModerationCommand(
              context,
              command: ModerationActionCommand(
                actionType: group.status == ModerationStatus.restricted
                    ? ModerationActionType.approve
                    : ModerationActionType.suspendUser,
                targetType: 'group',
                targetIds: [group.id],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GroupsViewModel {
  const _GroupsViewModel({
    required this.page,
    required this.query,
    required this.selectedIds,
    required this.categories,
    required this.moderators,
  });

  final ModerationPageSlice<ModerationGroup> page;
  final ModerationTableQuery query;
  final Set<String> selectedIds;
  final List<String> categories;
  final List<ModerationModeratorAccount> moderators;
}
