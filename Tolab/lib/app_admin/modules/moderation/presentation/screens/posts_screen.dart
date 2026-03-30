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

class ModerationPostsScreen extends StatelessWidget {
  const ModerationPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _PostsViewModel>(
      converter: (store) {
        final state = store.state.moderationState;
        return _PostsViewModel(
          page: selectPostsPage(store.state),
          query: state.postsQuery,
          selectedIds: state.selectedPostIds,
          groups: [
            'All',
            ...{
              for (final post in state.posts) post.groupName,
            },
          ],
        );
      },
      builder: (context, vm) {
        return Column(
          children: [
            ModerationFiltersBar(
              searchHint: 'Search posts by title, author, or group',
              searchValue: vm.query.searchQuery,
              onSearchChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(searchQuery: value, resetPage: true),
              ),
              statusOptions: const ['All', 'Active', 'Pending', 'Approved', 'Flagged', 'Removed'],
              selectedStatus: vm.query.statusFilter,
              onStatusChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(statusFilter: value, resetPage: true),
              ),
              secondaryLabel: 'Group',
              secondaryOptions: vm.groups,
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
                    label: 'Warn ${vm.selectedIds.length}',
                    icon: Icons.warning_amber_rounded,
                    isSecondary: true,
                    onPressed: () => dispatchModerationCommand(
                      context,
                      command: ModerationActionCommand(
                        actionType: ModerationActionType.warn,
                        targetType: 'post',
                        targetIds: vm.selectedIds.toList(growable: false),
                      ),
                    ),
                  ),
                if (vm.selectedIds.isNotEmpty)
                  PremiumButton(
                    label: 'Delete ${vm.selectedIds.length}',
                    icon: Icons.delete_outline_rounded,
                    isDestructive: true,
                    onPressed: () => dispatchModerationCommand(
                      context,
                      command: ModerationActionCommand(
                        actionType: ModerationActionType.deleteContent,
                        targetType: 'post',
                        targetIds: vm.selectedIds.toList(growable: false),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ModerationTableCard<ModerationPost>(
                title: 'Posts queue',
                subtitle:
                    'Review flagged or pending content before it spreads across student groups.',
                items: vm.page.items,
                columns: [
                  ModerationTableColumn<ModerationPost>(
                    key: 'title',
                    label: 'Title',
                    sortable: true,
                    size: ColumnSize.L,
                    cellBuilder: (context, post) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(post.title, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(post.bodyPreview, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  ModerationTableColumn<ModerationPost>(
                    key: 'author',
                    label: 'Author',
                    sortable: true,
                    cellBuilder: (context, post) => Text(post.authorName),
                  ),
                  ModerationTableColumn<ModerationPost>(
                    key: 'group',
                    label: 'Group',
                    cellBuilder: (context, post) => Text(post.groupName),
                  ),
                  ModerationTableColumn<ModerationPost>(
                    key: 'reports',
                    label: 'Status',
                    sortable: true,
                    cellBuilder: (context, post) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(post.status.label),
                        const SizedBox(width: AppSpacing.sm),
                        Text('${post.reportsCount} reports'),
                      ],
                    ),
                  ),
                  ModerationTableColumn<ModerationPost>(
                    key: 'createdAt',
                    label: 'Date',
                    sortable: true,
                    cellBuilder: (context, post) =>
                        Text(formatModerationDate(post.createdAt)),
                  ),
                  ModerationTableColumn<ModerationPost>(
                    key: 'actions',
                    label: 'Actions',
                    size: ColumnSize.S,
                    cellBuilder: (context, post) => IconButton(
                      onPressed: () => _openPreview(context, post),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                    ),
                  ),
                ],
                idOf: (post) => post.id,
                mobileTitleBuilder: (post) => post.title,
                mobileSubtitleBuilder: (post) =>
                    '${post.authorName}  •  ${post.groupName}',
                mobileBadgesBuilder: (context, post) => [
                  StatusBadge(post.status.label),
                  StatusBadge('${post.reportsCount} reports'),
                ],
                mobileFooterBuilder: (context, post) => [
                  Text(
                    formatModerationDate(post.createdAt),
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
                onRowTap: (post) => _openPreview(context, post),
                onToggleSelection: (itemId, selected) {
                  StoreProvider.of<AppState>(context).dispatch(
                    ModerationSelectionToggledAction(
                      section: ModerationSectionKey.posts,
                      itemId: itemId,
                      selected: selected,
                    ),
                  );
                },
                onToggleVisibleSelection: (selected) {
                  StoreProvider.of<AppState>(context).dispatch(
                    ModerationVisibleSelectionChangedAction(
                      section: ModerationSectionKey.posts,
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
        section: ModerationSectionKey.posts,
        query: query,
      ),
    );
  }

  Future<void> _openPreview(BuildContext context, ModerationPost post) async {
    await showModerationPreviewDialog(
      context: context,
      title: post.title,
      subtitle: '${post.authorName} in ${post.groupName}',
      status: post.status.label,
      content: post.bodyPreview,
      metadata: [
        MapEntry('Reports', post.reportsCount.toString()),
        MapEntry('Comments', post.commentsCount.toString()),
        MapEntry('Created', formatModerationDate(post.createdAt)),
      ],
      actions: [
        buildPreviewActionButton(
          label: 'Approve',
          icon: Icons.check_circle_outline_rounded,
          onPressed: () => dispatchModerationCommand(
            context,
            command: ModerationActionCommand(
              actionType: ModerationActionType.approve,
              targetType: 'post',
              targetIds: [post.id],
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
              targetType: 'post',
              targetIds: [post.id],
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
              targetType: 'post',
              targetIds: [post.id],
            ),
          ),
        ),
      ],
    );
  }
}

class _PostsViewModel {
  const _PostsViewModel({
    required this.page,
    required this.query,
    required this.selectedIds,
    required this.groups,
  });

  final ModerationPageSlice<ModerationPost> page;
  final ModerationTableQuery query;
  final Set<String> selectedIds;
  final List<String> groups;
}
