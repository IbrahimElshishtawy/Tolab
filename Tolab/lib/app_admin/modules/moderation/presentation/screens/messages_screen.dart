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
              searchHint: 'Search sender, receiver, or suspicious message text',
              searchValue: vm.query.searchQuery,
              onSearchChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(searchQuery: value, resetPage: true),
              ),
              statusOptions: const ['All', 'Pending', 'Approved', 'Flagged', 'Removed'],
              selectedStatus: vm.query.statusFilter,
              onStatusChanged: (value) => _updateQuery(
                context,
                vm.query.copyWith(statusFilter: value, resetPage: true),
              ),
              secondaryLabel: 'Risk',
              secondaryOptions: const ['All', 'High risk', 'Review'],
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
                title: 'Flagged messages',
                subtitle:
                    'Suspicious direct messages from campus communities and marketplace threads.',
                items: vm.page.items,
                columns: [
                  ModerationTableColumn<ModerationMessage>(
                    key: 'sender',
                    label: 'Sender',
                    sortable: true,
                    cellBuilder: (context, message) => Text(message.senderName),
                  ),
                  ModerationTableColumn<ModerationMessage>(
                    key: 'receiver',
                    label: 'Receiver',
                    sortable: true,
                    cellBuilder: (context, message) => Text(message.receiverName),
                  ),
                  ModerationTableColumn<ModerationMessage>(
                    key: 'message',
                    label: 'Message',
                    size: ColumnSize.L,
                    cellBuilder: (context, message) => Text(message.content),
                  ),
                  ModerationTableColumn<ModerationMessage>(
                    key: 'riskScore',
                    label: 'Risk',
                    sortable: true,
                    cellBuilder: (context, message) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(message.status.label),
                        const SizedBox(width: AppSpacing.sm),
                        Text('${(message.riskScore * 100).round()}%'),
                      ],
                    ),
                  ),
                  ModerationTableColumn<ModerationMessage>(
                    key: 'createdAt',
                    label: 'Date',
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
                  StatusBadge(message.status.label),
                  StatusBadge('${(message.riskScore * 100).round()}% risk'),
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
      subtitle: 'Suspicious private message',
      status: message.status.label,
      content: message.content,
      metadata: [
        MapEntry('Risk', '${(message.riskScore * 100).round()}%'),
        MapEntry('Created', formatModerationDate(message.createdAt)),
      ],
      actions: [
        buildPreviewActionButton(
          label: 'Approve',
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
          label: 'Warn',
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
          label: 'Delete',
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
