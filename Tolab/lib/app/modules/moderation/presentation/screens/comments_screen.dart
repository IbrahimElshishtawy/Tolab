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

class ModerationCommentsScreen extends StatelessWidget {
  const ModerationCommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _CommentsViewModel>(
      converter: (store) {
        final state = store.state.moderationState;
        return _CommentsViewModel(
          page: selectCommentsPage(store.state),
          query: state.commentsQuery,
          selectedIds: state.selectedCommentIds,
          posts: [
            'All',
            ...{
              for (final comment in state.comments) comment.postTitle,
            },
          ],
        );
      },
      builder: (context, vm) {
        return Column(
          children: [
            ModerationFiltersBar(
              searchHint: 'Search comments by content, post, or author',
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
              secondaryLabel: 'Post',
              secondaryOptions: vm.posts,
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
                    label: 'Approve ${vm.selectedIds.length}',
                    icon: Icons.check_circle_outline_rounded,
                    isSecondary: true,
                    onPressed: () => dispatchModerationCommand(
                      context,
                      command: ModerationActionCommand(
                        actionType: ModerationActionType.approve,
                        targetType: 'comment',
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
                        targetType: 'comment',
                        targetIds: vm.selectedIds.toList(growable: false),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ModerationTableCard<ModerationComment>(
                title: 'Comments by post',
                subtitle:
                    'Handle comment threads quickly before discussions escalate across groups.',
                items: vm.page.items,
                columns: [
                  ModerationTableColumn<ModerationComment>(
                    key: 'content',
                    label: 'Comment',
                    size: ColumnSize.L,
                    cellBuilder: (context, comment) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(comment.content, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(comment.postTitle, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  ModerationTableColumn<ModerationComment>(
                    key: 'author',
                    label: 'Author',
                    sortable: true,
                    cellBuilder: (context, comment) => Text(comment.authorName),
                  ),
                  ModerationTableColumn<ModerationComment>(
                    key: 'reports',
                    label: 'Status',
                    sortable: true,
                    cellBuilder: (context, comment) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(comment.status.label),
                        const SizedBox(width: AppSpacing.sm),
                        Text('${comment.reportsCount} reports'),
                      ],
                    ),
                  ),
                  ModerationTableColumn<ModerationComment>(
                    key: 'createdAt',
                    label: 'Date',
                    sortable: true,
                    cellBuilder: (context, comment) =>
                        Text(formatModerationDate(comment.createdAt)),
                  ),
                  ModerationTableColumn<ModerationComment>(
                    key: 'actions',
                    label: 'Actions',
                    size: ColumnSize.S,
                    cellBuilder: (context, comment) => IconButton(
                      onPressed: () => _openPreview(context, comment),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                    ),
                  ),
                ],
                idOf: (comment) => comment.id,
                mobileTitleBuilder: (comment) => comment.authorName,
                mobileSubtitleBuilder: (comment) => comment.content,
                mobileBadgesBuilder: (context, comment) => [
                  StatusBadge(comment.status.label),
                  StatusBadge(comment.postTitle),
                ],
                mobileFooterBuilder: (context, comment) => [
                  Text(
                    formatModerationDate(comment.createdAt),
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
                onRowTap: (comment) => _openPreview(context, comment),
                onToggleSelection: (itemId, selected) {
                  StoreProvider.of<AppState>(context).dispatch(
                    ModerationSelectionToggledAction(
                      section: ModerationSectionKey.comments,
                      itemId: itemId,
                      selected: selected,
                    ),
                  );
                },
                onToggleVisibleSelection: (selected) {
                  StoreProvider.of<AppState>(context).dispatch(
                    ModerationVisibleSelectionChangedAction(
                      section: ModerationSectionKey.comments,
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
        section: ModerationSectionKey.comments,
        query: query,
      ),
    );
  }

  Future<void> _openPreview(
    BuildContext context,
    ModerationComment comment,
  ) async {
    await showModerationPreviewDialog(
      context: context,
      title: comment.authorName,
      subtitle: comment.postTitle,
      status: comment.status.label,
      content: comment.content,
      metadata: [
        MapEntry('Reports', comment.reportsCount.toString()),
        MapEntry('Created', formatModerationDate(comment.createdAt)),
      ],
      actions: [
        buildPreviewActionButton(
          label: 'Approve',
          icon: Icons.check_circle_outline_rounded,
          onPressed: () => dispatchModerationCommand(
            context,
            command: ModerationActionCommand(
              actionType: ModerationActionType.approve,
              targetType: 'comment',
              targetIds: [comment.id],
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
              targetType: 'comment',
              targetIds: [comment.id],
            ),
          ),
        ),
        buildPreviewActionButton(
          label: 'Delete',
          icon: Icons.delete_outline_rounded,
          destructive: true,
          onPressed: () => dispatchModerationCommand(
            context,
            command: ModerationActionCommand(
              actionType: ModerationActionType.deleteContent,
              targetType: 'comment',
              targetIds: [comment.id],
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentsViewModel {
  const _CommentsViewModel({
    required this.page,
    required this.query,
    required this.selectedIds,
    required this.posts,
  });

  final ModerationPageSlice<ModerationComment> page;
  final ModerationTableQuery query;
  final Set<String> selectedIds;
  final List<String> posts;
}
