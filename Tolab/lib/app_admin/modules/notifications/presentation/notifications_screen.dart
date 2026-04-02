import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/models/notification_models.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/notifications_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final TextEditingController _broadcastTitleController;
  late final TextEditingController _broadcastBodyController;
  late final TextEditingController _broadcastAudienceController;
  late final TextEditingController _broadcastRefTypeController;
  late final TextEditingController _broadcastRefIdController;
  late final TextEditingController _historySearchController;

  AdminNotificationCategory? _centerCategory;
  AdminNotificationCategory? _historyCategory;
  NotificationHistoryDateFilter _historyDateFilter =
      NotificationHistoryDateFilter.all;
  bool _historyUnreadOnly = false;
  String? _selectedNotificationId;
  AdminNotificationCategory _broadcastCategory =
      AdminNotificationCategory.announcements;
  NotificationAudienceType _broadcastAudienceType =
      NotificationAudienceType.general;
  NotificationTone _broadcastTone = NotificationTone.message;
  NotificationDeliveryMode _broadcastDeliveryMode =
      NotificationDeliveryMode.instant;
  DateTime? _scheduledAt;

  @override
  void initState() {
    super.initState();
    _broadcastTitleController = TextEditingController();
    _broadcastBodyController = TextEditingController();
    _broadcastAudienceController = TextEditingController();
    _broadcastRefTypeController = TextEditingController();
    _broadcastRefIdController = TextEditingController();
    _historySearchController = TextEditingController();
  }

  @override
  void dispose() {
    _broadcastTitleController.dispose();
    _broadcastBodyController.dispose();
    _broadcastAudienceController.dispose();
    _broadcastRefTypeController.dispose();
    _broadcastRefIdController.dispose();
    _historySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NotificationsState>(
      onInit: (store) => store.dispatch(const LoadNotificationsAction()),
      converter: (store) => store.state.notificationsState,
      builder: (context, state) {
        final centerItems = _applyCenterFilter(state.items);
        final selectedNotification = centerItems.firstWhereOrNull(
          (item) => item.id == _selectedNotificationId,
        );
        final resolvedSelected =
            selectedNotification ?? centerItems.firstOrNull;
        final historyItems = _applyHistoryFilters(state.items);

        return DefaultTabController(
          initialIndex: widget.initialTabIndex,
          length: 2,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final workspaceHeight =
                  (constraints.maxHeight * 0.64).clamp(420.0, 860.0).toDouble();

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageHeader(
                        title: 'Notification Center',
                        subtitle:
                            'Realtime operational updates, delivery history, and quick actions for academic, system, and message events.',
                        breadcrumbs: const ['Admin', 'Notifications'],
                        actions: [
                          PremiumButton(
                            label: 'Refresh',
                            icon: Icons.refresh_rounded,
                            onPressed: () => StoreProvider.of<AppState>(
                              context,
                              listen: false,
                            ).dispatch(const LoadNotificationsAction()),
                          ),
                          PremiumButton(
                            label: 'Mark all read',
                            icon: Icons.done_all_rounded,
                            onPressed: state.unreadCount == 0
                                ? null
                                : () => StoreProvider.of<AppState>(
                                      context,
                                      listen: false,
                                    ).dispatch(
                                      const MarkAllNotificationsReadRequestedAction(),
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _NotificationOverviewStrip(state: state),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: const TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          tabs: [
                            Tab(text: 'Center'),
                            Tab(text: 'History'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: workspaceHeight,
                        child: AsyncStateView(
                          status: state.status,
                          errorMessage: state.errorMessage,
                          onRetry: () => StoreProvider.of<AppState>(
                            context,
                            listen: false,
                          ).dispatch(const LoadNotificationsAction()),
                          child: TabBarView(
                            children: [
                              _buildCenterTab(
                                context,
                                state: state,
                                items: centerItems,
                                selected: resolvedSelected,
                              ),
                              _buildHistoryTab(
                                context,
                                state: state,
                                items: historyItems,
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
          ),
        );
      },
    );
  }

  Widget _buildCenterTab(
    BuildContext context, {
    required NotificationsState state,
    required List<AdminNotification> items,
    required AdminNotification? selected,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1120;
        final listPanel = Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Live inbox',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      StatusBadge(
                        state.connectionStatus.label,
                        icon: Icons.wifi_tethering_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      FilterChip(
                        label: Text('All (${state.items.length})'),
                        selected: _centerCategory == null,
                        onSelected: (_) =>
                            setState(() => _centerCategory = null),
                      ),
                      for (final category in AdminNotificationCategory.values)
                        FilterChip(
                          label: Text(
                            '${category.label} (${state.unreadByCategory[category] ?? 0})',
                          ),
                          selected: _centerCategory == category,
                          onSelected: (_) =>
                              setState(() => _centerCategory = category),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: items.isEmpty
                  ? const _NotificationsEmptyState(
                      title: 'No notifications match this filter',
                      subtitle:
                          'Try switching categories or wait for the next realtime event.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _NotificationListCard(
                          notification: item,
                          selected: item.id == selected?.id,
                          onTap: () => setState(() {
                            _selectedNotificationId = item.id;
                          }),
                          onAction: (action) =>
                              _handleQuickAction(context, item, action),
                        );
                      },
                    ),
            ),
          ],
        );

        final detailPanel = SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            children: [
              _NotificationDetailCard(
                notification: selected,
                onAction: selected == null
                    ? null
                    : (action) => _handleQuickAction(context, selected, action),
              ),
              const SizedBox(height: AppSpacing.md),
              _BroadcastComposerCard(
                titleController: _broadcastTitleController,
                bodyController: _broadcastBodyController,
                audienceController: _broadcastAudienceController,
                refTypeController: _broadcastRefTypeController,
                refIdController: _broadcastRefIdController,
                selectedCategory: _broadcastCategory,
                selectedAudienceType: _broadcastAudienceType,
                selectedTone: _broadcastTone,
                deliveryMode: _broadcastDeliveryMode,
                scheduledAt: _scheduledAt,
                isSubmitting: state.isBroadcasting,
                onCategoryChanged: (value) {
                  if (value == null) return;
                  setState(() => _broadcastCategory = value);
                },
                onAudienceTypeChanged: (value) {
                  if (value == null) return;
                  setState(() => _broadcastAudienceType = value);
                },
                onToneChanged: (value) {
                  if (value == null) return;
                  setState(() => _broadcastTone = value);
                },
                onDeliveryModeChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _broadcastDeliveryMode = value;
                    if (value == NotificationDeliveryMode.instant) {
                      _scheduledAt = null;
                    }
                  });
                },
                onScheduleTap: () => _pickSchedule(context),
                onSubmit: () => _submitBroadcast(context),
              ),
            ],
          ),
        );

        if (!isWide) {
          return Column(
            children: [
              Expanded(flex: 7, child: listPanel),
              const SizedBox(height: AppSpacing.md),
              Expanded(flex: 6, child: detailPanel),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: listPanel),
            const SizedBox(width: AppSpacing.md),
            Expanded(flex: 5, child: detailPanel),
          ],
        );
      },
    );
  }

  Widget _buildHistoryTab(
    BuildContext context, {
    required NotificationsState state,
    required List<AdminNotification> items,
  }) {
    return Column(
      children: [
        AppCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              final searchField = TextField(
                controller: _historySearchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search title, body, category, or audience',
                ),
              );
              final dateField =
                  DropdownButtonFormField<NotificationHistoryDateFilter>(
                    key: ValueKey(_historyDateFilter),
                    initialValue: _historyDateFilter,
                    items: [
                      for (final filter in NotificationHistoryDateFilter.values)
                        DropdownMenuItem(
                          value: filter,
                          child: Text(filter.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _historyDateFilter = value);
                    },
                    decoration: const InputDecoration(labelText: 'Date range'),
                  );

              return Column(
                children: [
                  if (compact) ...[
                    searchField,
                    const SizedBox(height: AppSpacing.md),
                    dateField,
                  ] else
                    Row(
                      children: [
                        Expanded(flex: 2, child: searchField),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: dateField),
                      ],
                    ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilterChip(
                    label: const Text('Unread only'),
                    selected: _historyUnreadOnly,
                    onSelected: (value) =>
                        setState(() => _historyUnreadOnly = value),
                  ),
                  FilterChip(
                    label: const Text('All categories'),
                    selected: _historyCategory == null,
                    onSelected: (_) => setState(() => _historyCategory = null),
                  ),
                  for (final category in AdminNotificationCategory.values)
                    FilterChip(
                      label: Text(category.label),
                      selected: _historyCategory == category,
                      onSelected: (_) =>
                          setState(() => _historyCategory = category),
                    ),
                ],
              ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: items.isEmpty
              ? const _NotificationsEmptyState(
                  title: 'No notifications in this history window',
                  subtitle:
                      'Widen the date range or remove filters to inspect older activity.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NotificationIcon(category: item.category),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: [
                                    Text(
                                      item.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    StatusBadge(
                                      item.isRead ? 'Read' : 'Unread',
                                      icon: item.isRead
                                          ? Icons.drafts_outlined
                                          : Icons.mark_email_unread_rounded,
                                    ),
                                    StatusBadge(item.category.label),
                                    if (item.tone != null)
                                      StatusBadge(item.tone!.label),
                                    if (item.isScheduled)
                                      StatusBadge(
                                        'Scheduled ${DateFormat('dd MMM, HH:mm').format(item.scheduledAt!)}',
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  item.body,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  '${item.createdAtLabel}${item.audienceLabel == null ? '' : ' • ${item.audienceLabel}'}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            children: [
                              OutlinedButton(
                                onPressed: () => _handleQuickAction(
                                  context,
                                  item,
                                  NotificationQuickActionType.open,
                                ),
                                child: const Text('Open'),
                              ),
                              if (!item.isRead) ...[
                                const SizedBox(height: AppSpacing.sm),
                                TextButton(
                                  onPressed: () =>
                                      StoreProvider.of<AppState>(
                                        context,
                                        listen: false,
                                      ).dispatch(
                                        MarkNotificationReadRequestedAction(
                                          item.id,
                                        ),
                                      ),
                                  child: const Text('Mark read'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<AdminNotification> _applyCenterFilter(List<AdminNotification> items) {
    return items
        .where(
          (item) => _centerCategory == null || item.category == _centerCategory,
        )
        .toList(growable: false);
  }

  List<AdminNotification> _applyHistoryFilters(List<AdminNotification> items) {
    final query = _historySearchController.text;
    final now = DateTime.now();
    return items
        .where((item) {
          final categoryMatch =
              _historyCategory == null || item.category == _historyCategory;
          final unreadMatch = !_historyUnreadOnly || !item.isRead;
          final dateMatch = _historyDateFilter.matches(item.createdAt, now);
          final queryMatch = item.matchesQuery(query);
          return categoryMatch && unreadMatch && dateMatch && queryMatch;
        })
        .toList(growable: false);
  }

  Future<void> _submitBroadcast(BuildContext context) async {
    final title = _broadcastTitleController.text.trim();
    final body = _broadcastBodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and message are required.')),
      );
      return;
    }
    if (_broadcastDeliveryMode == NotificationDeliveryMode.scheduled &&
        _scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a schedule date and time first.')),
      );
      return;
    }

    StoreProvider.of<AppState>(context, listen: false).dispatch(
      NotificationBroadcastRequestedAction(
        title: title,
        body: body,
        category: _broadcastCategory,
        audienceType: _broadcastAudienceType,
        tone: _broadcastTone,
        audienceLabel: _broadcastAudienceController.text.trim().isEmpty
            ? null
            : _broadcastAudienceController.text.trim(),
        scheduledAt: _broadcastDeliveryMode == NotificationDeliveryMode.scheduled
            ? _scheduledAt
            : null,
        refType: _broadcastRefTypeController.text.trim().isEmpty
            ? null
            : _broadcastRefTypeController.text.trim(),
        refId: _broadcastRefIdController.text.trim().isEmpty
            ? null
            : _broadcastRefIdController.text.trim(),
        onSuccess: (notification) {
          _broadcastTitleController.clear();
          _broadcastBodyController.clear();
          _broadcastAudienceController.clear();
          _broadcastRefTypeController.clear();
          _broadcastRefIdController.clear();
          setState(() {
            _broadcastDeliveryMode = NotificationDeliveryMode.instant;
            _scheduledAt = null;
            _broadcastTone = NotificationTone.message;
            _broadcastAudienceType = NotificationAudienceType.general;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                notification.source == 'local-fallback'
                    ? 'Saved locally until the backend notification API is available.'
                    : 'Broadcast queued successfully.',
              ),
            ),
          );
        },
        onError: (message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      ),
    );
  }

  Future<void> _pickSchedule(BuildContext context) async {
    final now = DateTime.now();
    final initial = _scheduledAt ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted || time == null) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _broadcastDeliveryMode = NotificationDeliveryMode.scheduled;
    });
  }

  Future<void> _handleQuickAction(
    BuildContext context,
    AdminNotification notification,
    NotificationQuickActionType action,
  ) async {
    StoreProvider.of<AppState>(
      context,
      listen: false,
    ).dispatch(MarkNotificationReadRequestedAction(notification.id));

    switch (action) {
      case NotificationQuickActionType.open:
        context.go(_routeFor(notification));
        return;
      case NotificationQuickActionType.approve:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Approved: ${notification.title}')),
        );
        return;
      case NotificationQuickActionType.reply:
        await _openReplySheet(context, notification);
        return;
    }
  }

  Future<void> _openReplySheet(
    BuildContext context,
    AdminNotification notification,
  ) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reply to ${notification.category.label}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                notification.title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Reply',
                  hintText: 'Write a response for the selected alert',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              controller.text.trim().isEmpty
                                  ? 'Reply draft saved.'
                                  : 'Reply sent for ${notification.title}.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Send reply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
  }

  String _routeFor(AdminNotification notification) {
    final refType = (notification.refType ?? '').toLowerCase();
    if (refType.contains('schedule')) return RoutePaths.schedule;
    if (refType.contains('message')) return RoutePaths.moderation;
    if (refType.contains('content') ||
        refType.contains('campaign') ||
        refType.contains('announcement')) {
      return RoutePaths.content;
    }
    if (refType.contains('setting') ||
        notification.category == AdminNotificationCategory.system) {
      return RoutePaths.settings;
    }
    if (refType.contains('enrollment') || refType.contains('student')) {
      return RoutePaths.enrollments;
    }
    return switch (notification.category) {
      AdminNotificationCategory.academic => RoutePaths.students,
      AdminNotificationCategory.messages => RoutePaths.moderation,
      AdminNotificationCategory.system => RoutePaths.settings,
      AdminNotificationCategory.announcements => RoutePaths.content,
    };
  }
}

class _NotificationOverviewStrip extends StatelessWidget {
  const _NotificationOverviewStrip({required this.state});

  final NotificationsState state;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        label: 'Unread alerts',
        value: '${state.unreadCount}',
        icon: Icons.mark_email_unread_rounded,
        color: AppColors.primary,
      ),
      (
        label: 'Academic queue',
        value:
            '${state.unreadByCategory[AdminNotificationCategory.academic] ?? 0}',
        icon: Icons.school_rounded,
        color: AppColors.secondary,
      ),
      (
        label: 'Message reviews',
        value:
            '${state.unreadByCategory[AdminNotificationCategory.messages] ?? 0}',
        icon: Icons.chat_bubble_rounded,
        color: AppColors.info,
      ),
      (
        label: 'Realtime state',
        value: state.connectionStatus.label,
        icon: Icons.bolt_rounded,
        color: AppColors.warning,
      ),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final metric in metrics)
          SizedBox(
            width: 220,
            child: AppCard(
              child: Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: metric.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(metric.icon, color: metric.color),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metric.label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metric.value,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationListCard extends StatelessWidget {
  const _NotificationListCard({
    required this.notification,
    required this.selected,
    required this.onTap,
    required this.onAction,
  });

  final AdminNotification notification;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<NotificationQuickActionType> onAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      interactive: true,
      onTap: onTap,
      borderColor: selected
          ? _accent(notification.category).withValues(alpha: 0.28)
          : null,
      backgroundColor: selected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.04)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(category: notification.category),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (!notification.isRead)
                          const StatusBadge(
                            'Unread',
                            icon: Icons.fiber_manual_record_rounded,
                          ),
                        StatusBadge(notification.category.label),
                        if (notification.tone != null)
                          StatusBadge(notification.tone!.label),
                        if (notification.isScheduled)
                          StatusBadge(
                            'Scheduled ${DateFormat('dd MMM, HH:mm').format(notification.scheduledAt!)}',
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${notification.createdAtLabel}${notification.audienceLabel == null ? '' : ' • ${notification.audienceLabel}'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final action in notification.quickActions)
                action.type == NotificationQuickActionType.open
                    ? FilledButton.tonal(
                        onPressed: () => onAction(action.type),
                        child: Text(action.type.label),
                      )
                    : OutlinedButton(
                        onPressed: () => onAction(action.type),
                        child: Text(action.type.label),
                      ),
            ],
          ),
        ],
      ),
    );
  }

  Color _accent(AdminNotificationCategory category) => switch (category) {
    AdminNotificationCategory.academic => AppColors.primary,
    AdminNotificationCategory.messages => AppColors.info,
    AdminNotificationCategory.system => AppColors.warning,
    AdminNotificationCategory.announcements => AppColors.secondary,
  };
}

class _NotificationDetailCard extends StatelessWidget {
  const _NotificationDetailCard({
    required this.notification,
    required this.onAction,
  });

  final AdminNotification? notification;
  final ValueChanged<NotificationQuickActionType>? onAction;

  @override
  Widget build(BuildContext context) {
    if (notification == null) {
      return const _NotificationsEmptyState(
        title: 'Select an alert',
        subtitle:
            'Choose a notification from the inbox to inspect metadata and trigger quick actions.',
      );
    }

    final item = notification!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusBadge(item.category.label),
              StatusBadge(item.isRead ? 'Read' : 'Unread'),
              if (item.tone != null) StatusBadge(item.tone!.label),
              if (item.isScheduled)
                StatusBadge(
                  'Scheduled ${DateFormat('dd MMM, HH:mm').format(item.scheduledAt!)}',
                ),
              if (item.source.isNotEmpty)
                StatusBadge(item.source.toUpperCase()),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(item.body, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Received', value: item.createdAtLabel),
          _DetailRow(label: 'Reference type', value: item.refType ?? 'None'),
          _DetailRow(label: 'Reference ID', value: item.refId ?? 'None'),
          _DetailRow(label: 'Audience', value: item.audienceLabel ?? 'General'),
          _DetailRow(
            label: 'Target type',
            value: item.audienceType?.label ?? 'General',
          ),
          _DetailRow(label: 'Tone', value: item.tone?.label ?? 'Message'),
          if (item.scheduledAt != null)
            _DetailRow(
              label: 'Scheduled for',
              value: DateFormat('dd MMM yyyy, HH:mm').format(item.scheduledAt!),
            ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final action in item.quickActions)
                action.type == NotificationQuickActionType.open
                    ? FilledButton(
                        onPressed: onAction == null
                            ? null
                            : () => onAction!(action.type),
                        child: Text(action.type.label),
                      )
                    : OutlinedButton(
                        onPressed: onAction == null
                            ? null
                            : () => onAction!(action.type),
                        child: Text(action.type.label),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BroadcastComposerCard extends StatelessWidget {
  const _BroadcastComposerCard({
    required this.titleController,
    required this.bodyController,
    required this.audienceController,
    required this.refTypeController,
    required this.refIdController,
    required this.selectedCategory,
    required this.selectedAudienceType,
    required this.selectedTone,
    required this.deliveryMode,
    required this.scheduledAt,
    required this.isSubmitting,
    required this.onCategoryChanged,
    required this.onAudienceTypeChanged,
    required this.onToneChanged,
    required this.onDeliveryModeChanged,
    required this.onScheduleTap,
    required this.onSubmit,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;
  final TextEditingController audienceController;
  final TextEditingController refTypeController;
  final TextEditingController refIdController;
  final AdminNotificationCategory selectedCategory;
  final NotificationAudienceType selectedAudienceType;
  final NotificationTone selectedTone;
  final NotificationDeliveryMode deliveryMode;
  final DateTime? scheduledAt;
  final bool isSubmitting;
  final ValueChanged<AdminNotificationCategory?> onCategoryChanged;
  final ValueChanged<NotificationAudienceType?> onAudienceTypeChanged;
  final ValueChanged<NotificationTone?> onToneChanged;
  final ValueChanged<NotificationDeliveryMode?> onDeliveryModeChanged;
  final VoidCallback onScheduleTap;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Broadcast studio',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Send academic messages to cohorts or doctors, raise alerts or warnings, and schedule delivery times when the backend is available.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              final categoryField =
                  DropdownButtonFormField<AdminNotificationCategory>(
                    key: ValueKey(selectedCategory),
                    initialValue: selectedCategory,
                    items: [
                      for (final category in AdminNotificationCategory.values)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category.label),
                        ),
                    ],
                    onChanged: onCategoryChanged,
                    decoration: const InputDecoration(labelText: 'Category'),
                  );
              final audienceField =
                  DropdownButtonFormField<NotificationAudienceType>(
                    key: ValueKey(selectedAudienceType),
                    initialValue: selectedAudienceType,
                    items: [
                      for (final audienceType in NotificationAudienceType.values)
                        DropdownMenuItem(
                          value: audienceType,
                          child: Text(audienceType.label),
                        ),
                    ],
                    onChanged: onAudienceTypeChanged,
                    decoration: const InputDecoration(labelText: 'Target group'),
                  );
              final toneField = DropdownButtonFormField<NotificationTone>(
                    key: ValueKey(selectedTone),
                    initialValue: selectedTone,
                    items: [
                      for (final tone in NotificationTone.values)
                        DropdownMenuItem(
                          value: tone,
                          child: Text(tone.label),
                        ),
                    ],
                    onChanged: onToneChanged,
                    decoration: const InputDecoration(labelText: 'Tone'),
                  );

              if (compact) {
                return Column(
                  children: [
                    categoryField,
                    const SizedBox(height: AppSpacing.md),
                    audienceField,
                    const SizedBox(height: AppSpacing.md),
                    toneField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: categoryField),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: audienceField),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: toneField),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: bodyController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Describe the operational event or announcement',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: audienceController,
            decoration: InputDecoration(
              labelText: 'Audience details',
              hintText: switch (selectedAudienceType) {
                NotificationAudienceType.cohorts =>
                  'Batch 2026, Level 3, Section A',
                NotificationAudienceType.doctors =>
                  'All CS doctors or Dr. Laila Hassan',
                NotificationAudienceType.departments =>
                  'Computer Science, Information Systems',
                _ => 'Optional specific audience label',
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              final refTypeField = TextField(
                controller: refTypeController,
                decoration: const InputDecoration(
                  labelText: 'Reference type',
                  hintText: 'schedule / enrollment / message',
                ),
              );
              final refIdField = TextField(
                controller: refIdController,
                decoration: const InputDecoration(
                  labelText: 'Reference ID',
                  hintText: 'Optional',
                ),
              );

              if (compact) {
                return Column(
                  children: [
                    refTypeField,
                    const SizedBox(height: AppSpacing.md),
                    refIdField,
                  ],
                ),
              }

              return Row(
                children: [
                  Expanded(child: refTypeField),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: refIdField),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              final modeField =
                  DropdownButtonFormField<NotificationDeliveryMode>(
                    key: ValueKey(deliveryMode),
                    initialValue: deliveryMode,
                    items: [
                      for (final mode in NotificationDeliveryMode.values)
                        DropdownMenuItem(
                          value: mode,
                          child: Text(mode.label),
                        ),
                    ],
                    onChanged: onDeliveryModeChanged,
                    decoration: const InputDecoration(labelText: 'Delivery'),
                  );
              final scheduleField = OutlinedButton.icon(
                onPressed: onScheduleTap,
                icon: const Icon(Icons.schedule_rounded),
                label: Text(
                  scheduledAt == null
                      ? 'Pick schedule'
                      : DateFormat('dd MMM, HH:mm').format(scheduledAt!),
                ),
              );

              if (compact) {
                return Column(
                  children: [
                    modeField,
                    const SizedBox(height: AppSpacing.md),
                    scheduleField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: modeField),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: scheduleField),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: Text(isSubmitting ? 'Queueing...' : 'Queue notification'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.category});

  final AdminNotificationCategory category;

  @override
  Widget build(BuildContext context) {
    final color = switch (category) {
      AdminNotificationCategory.academic => AppColors.primary,
      AdminNotificationCategory.messages => AppColors.info,
      AdminNotificationCategory.system => AppColors.warning,
      AdminNotificationCategory.announcements => AppColors.secondary,
    };
    final icon = switch (category) {
      AdminNotificationCategory.academic => Icons.school_rounded,
      AdminNotificationCategory.messages => Icons.mark_chat_unread_rounded,
      AdminNotificationCategory.system => Icons.settings_suggest_rounded,
      AdminNotificationCategory.announcements => Icons.campaign_rounded,
    };

    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
