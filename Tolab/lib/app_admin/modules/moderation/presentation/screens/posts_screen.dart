import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:tolab_fci/app/localization/app_localizations.dart';
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
              searchHint: context.l10n.byValue('Search posts by title, author, or group'),
              searchValue: vm.query.searchQuery,
              onSearchChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(searchQuery: value, resetPage: true),
              ),
              statusOptions: ['All', 'Active', 'Pending', 'Approved', 'Flagged', 'Removed'].map(context.l10n.byValue).toList(),
              selectedStatus: vm.query.statusFilter,
              onStatusChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(statusFilter: value, resetPage: true),
              ),
              secondaryLabel: context.l10n.byValue('Group'),
              secondaryOptions: vm.groups,
              selectedSecondary: vm.query.secondaryFilter,
              onSecondaryChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(secondaryFilter: value, resetPage: true),
              ),
              dateOptions: ['Any time', 'Today', 'Last 7 days', 'Last 30 days'].map(context.l10n.byValue).toList(),
              selectedDate: vm.query.dateFilter,
              onDateChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(dateFilter: value, resetPage: true),
              ),
              trailing: [
                if (vm.selectedIds.isNotEmpty)
                  PremiumButton(
                    label: '${context.l10n.byValue('Warn')} (${vm.selectedIds.length})',
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
                    label: '${context.l10n.byValue('Delete')} (${vm.selectedIds.length})',
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
                title: context.l10n.byValue('Posts queue'),
                subtitle: context.l10n.byValue(
                    'Review flagged or pending content before it spreads across student groups.'),
                items: vm.page.items,
                columns: [
                  ModerationTableColumn<ModerationPost>(
                    key: 'title',
                    label: context.l10n.byValue('Title'),
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
                    label: context.l10n.byValue('Author'),
                    sortable: true,
                    cellBuilder: (context, post) => Text(post.authorName),
                  ),
                  ModerationTableColumn<ModerationPost>(
                    key: 'group',
                    label: context.l10n.byValue('Group'),
                    cellBuilder: (context, post) => Text(post.groupName),
                  ),
                  ModerationTableColumn<ModerationPost>(
                    key: 'reports',
                    label: context.l10n.byValue('Status'),
                    sortable: true,
                    cellBuilder: (context, post) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(context.l10n.byValue(post.status.label)),
                        const SizedBox(width: AppSpacing.sm),
                        Text('${post.reportsCount} ${context.l10n.byValue('Reports')}'),
                      ],
                    ),
                  ),
                  ModerationTableColumn<ModerationPost>(
                    key: 'createdAt',
                    label: context.l10n.byValue('Date'),
                    sortable: true,
                    cellBuilder: (context, post) =>
                        Text(formatModerationDate(post.createdAt)),
                  ),
                  ModerationTableColumn<ModerationPost>(
                    key: 'actions',
                    label: context.l10n.byValue('Actions'),
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
      subtitle: '${post.authorName} ${context.l10n.byValue('in')} ${post.groupName}',
      status: context.l10n.byValue(post.status.label),
      content: post.bodyPreview,
      metadata: [
        MapEntry(context.l10n.byValue('Reports'), post.reportsCount.toString()),
        MapEntry(context.l10n.byValue('Comments'), post.commentsCount.toString()),
        MapEntry(context.l10n.byValue('Date'), formatModerationDate(post.createdAt)),
      ],
      actions: [
        buildPreviewActionButton(
          label: context.l10n.byValue('Approve'),
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
          label: context.l10n.byValue('Warn'),
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
          label: context.l10n.byValue('Reply'),
          icon: Icons.reply_rounded,
          onPressed: () {
            Navigator.of(context).pop();
            showModerationReplyDialog(
              context: context,
              recipientName: post.authorName,
              contentPreview: post.bodyPreview,
              contentTypeLabel: 'post',
              onSend: (replyText) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      replyText.isEmpty
                          ? context.l10n.byValue('Reply sent successfully.')
                          : '${context.l10n.byValue('Official response sent to student.')}: "$replyText"',
                    ),
                  ),
                );
              },
            );
          },
        ),
        buildPreviewActionButton(
          label: context.l10n.byValue('Remove'),
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
