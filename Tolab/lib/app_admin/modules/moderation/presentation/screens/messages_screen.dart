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

class ModerationMessagesScreen extends StatelessWidget {
  const ModerationMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _MessagesViewModel>(
      converter: (store) {
        final state = store.state.moderationState;
        return _MessagesViewModel(
          page: selectMessagesPage(store.state),
          query: state.messagesQuery,
          selectedIds: state.selectedMessageIds,
        );
      },
      builder: (context, vm) {
        return Column(
          children: [
            ModerationFiltersBar(
              searchHint: context.l10n.byValue('Search sender, receiver, or suspicious message text'),
              searchValue: vm.query.searchQuery,
              onSearchChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(searchQuery: value, resetPage: true),
              ),
              statusOptions: ['All', 'Pending', 'Approved', 'Flagged', 'Removed'].map(context.l10n.byValue).toList(),
              selectedStatus: vm.query.statusFilter,
              onStatusChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(statusFilter: value, resetPage: true),
              ),
              secondaryLabel: context.l10n.byValue('Risk'),
              secondaryOptions: ['All', 'High risk', 'Review'].map(context.l10n.byValue).toList(),
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
                        targetType: 'message',
                        targetIds: vm.selectedIds.toList(growable: false),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ModerationTableCard<ModerationMessage>(
                title: context.l10n.byValue('Flagged messages'),
                subtitle: context.l10n.byValue(
                    'Suspicious direct messages from campus communities and marketplace threads.'),
                items: vm.page.items,
                columns: [
                  ModerationTableColumn<ModerationMessage>(
                    key: 'sender',
                    label: context.l10n.byValue('Sender'),
                    sortable: true,
                    cellBuilder: (context, message) => Text(message.senderName),
                  ),
                  ModerationTableColumn<ModerationMessage>(
                    key: 'receiver',
                    label: context.l10n.byValue('Receiver'),
                    sortable: true,
                    cellBuilder: (context, message) => Text(message.receiverName),
                  ),
                  ModerationTableColumn<ModerationMessage>(
                    key: 'message',
                    label: context.l10n.byValue('Message'),
                    size: ColumnSize.L,
                    cellBuilder: (context, message) => Text(message.content),
                  ),
                  ModerationTableColumn<ModerationMessage>(
                    key: 'riskScore',
                    label: context.l10n.byValue('Risk'),
                    sortable: true,
                    cellBuilder: (context, message) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(context.l10n.byValue(message.status.label)),
                        const SizedBox(width: AppSpacing.sm),
                        Text('${(message.riskScore * 100).round()}%'),
                      ],
                    ),
                  ),
                  ModerationTableColumn<ModerationMessage>(
                    key: 'createdAt',
                    label: context.l10n.byValue('Date'),
                    sortable: true,
                    cellBuilder: (context, message) =>
                        Text(formatModerationDate(message.createdAt)),
                  ),
                ],
                idOf: (message) => message.id,
                mobileTitleBuilder: (message) =>
                    '${message.senderName} → ${message.receiverName}',
                mobileSubtitleBuilder: (message) => message.content,
                mobileBadgesBuilder: (context, message) => [
                  StatusBadge(context.l10n.byValue(message.status.label)),
                  StatusBadge('${(message.riskScore * 100).round()}% ${context.l10n.byValue('Risk')}'),
                ],
                mobileFooterBuilder: (context, message) => [
                  Text(
                    formatModerationDate(message.createdAt),
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
                onRowTap: (message) => _openPreview(context, message),
                onToggleSelection: (itemId, selected) {
                  StoreProvider.of<AppState>(context).dispatch(
                    ModerationSelectionToggledAction(
                      section: ModerationSectionKey.messages,
                      itemId: itemId,
                      selected: selected,
                    ),
                  );
                },
                onToggleVisibleSelection: (selected) {
                  StoreProvider.of<AppState>(context).dispatch(
                    ModerationVisibleSelectionChangedAction(
                      section: ModerationSectionKey.messages,
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
        section: ModerationSectionKey.messages,
        query: query,
      ),
    );
  }

  Future<void> _openPreview(
    BuildContext context,
    ModerationMessage message,
  ) async {
    await showModerationPreviewDialog(
      context: context,
      title: '${message.senderName} → ${message.receiverName}',
      subtitle: context.l10n.byValue('Suspicious private message'),
      status: context.l10n.byValue(message.status.label),
      content: message.content,
      metadata: [
        MapEntry(context.l10n.byValue('Risk'), '${(message.riskScore * 100).round()}%'),
        MapEntry(context.l10n.byValue('Date'), formatModerationDate(message.createdAt)),
      ],
      actions: [
        buildPreviewActionButton(
          label: context.l10n.byValue('Approve'),
          icon: Icons.check_circle_outline_rounded,
          onPressed: () => dispatchModerationCommand(
            context,
            command: ModerationActionCommand(
              actionType: ModerationActionType.approve,
              targetType: 'message',
              targetIds: [message.id],
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
              targetType: 'message',
              targetIds: [message.id],
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
              recipientName: message.senderName,
              contentPreview: message.content,
              contentTypeLabel: 'private message',
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
          label: context.l10n.byValue('Delete'),
          icon: Icons.delete_outline_rounded,
          destructive: true,
          onPressed: () => dispatchModerationCommand(
            context,
            command: ModerationActionCommand(
              actionType: ModerationActionType.deleteContent,
              targetType: 'message',
              targetIds: [message.id],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessagesViewModel {
  const _MessagesViewModel({
    required this.page,
    required this.query,
    required this.selectedIds,
  });

  final ModerationPageSlice<ModerationMessage> page;
  final ModerationTableQuery query;
  final Set<String> selectedIds;
}
