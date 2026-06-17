import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/models/notification_item.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/repositories/mock_notifications_repository.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_filters.dart';
import '../widgets/notification_group.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: notificationsAsync.when(
          data: (notifications) {
            final filtered = notifications.where((item) {
              return switch (_filter) {
                'unread' => !item.isRead,
                'important' => item.isImportant,
                _ => true,
              };
            }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            final today = DateTime.now();
            final dayStart = DateTime(today.year, today.month, today.day);
            final weekStart = dayStart.subtract(
              Duration(days: today.weekday - 1),
            );

            final todayItems = filtered
                .where((item) => item.createdAt.isAfter(dayStart))
                .toList();
            final weekItems = filtered
                .where(
                  (item) =>
                      item.createdAt.isAfter(weekStart) &&
                      item.createdAt.isBefore(dayStart),
                )
                .toList();
            final olderItems = filtered
                .where((item) => item.createdAt.isBefore(weekStart))
                .toList();

            return ListView(
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('التنبيهات', 'Notifications'),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        context.tr(
                          'تنبيهات أكاديمية قابلة للاستخدام الفعلي، مع تصفية سريعة، والوصول المباشر للعنصر المرتبط.',
                          'Academic notifications for practical use, with quick filtering and direct access to the related items.',
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      NotificationFilters(
                        selectedFilter: _filter,
                        onFilterSelected: (newFilter) {
                          setState(() => _filter = newFilter);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  EmptyStateWidget(
                    title: context.tr(
                      'لا توجد تنبيهات ضمن هذا العرض',
                      'No notifications under this filter',
                    ),
                    subtitle: context.tr(
                      'غيّر الفلاتر لعرض المزيد من التحديثات.',
                      'Change the filters to see more updates.',
                    ),
                  )
                else ...[
                  if (todayItems.isNotEmpty)
                    NotificationGroup(
                      title: context.tr('اليوم', 'Today'),
                      items: todayItems,
                      onOpen: _openNotification,
                    ),
                  if (weekItems.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    NotificationGroup(
                      title: context.tr('هذا الأسبوع', 'This Week'),
                      items: weekItems,
                      onOpen: _openNotification,
                    ),
                  ],
                  if (olderItems.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    NotificationGroup(
                      title: context.tr('أقدم', 'Older'),
                      items: olderItems,
                      onOpen: _openNotification,
                    ),
                  ],
                ],
              ],
            );
          },
          loading: () => LoadingWidget(
            label: context.tr('جارٍ تحميل التنبيهات...', 'Loading notifications...'),
          ),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }

  Future<void> _openNotification(
    BuildContext context,
    AppNotificationItem item,
  ) async {
    if (!item.isRead) {
      await ref.read(notificationsRepositoryProvider).markAsRead(item.id);
    }
    if (!context.mounted) {
      return;
    }
    context.goNamed(item.routeName, pathParameters: item.pathParameters);
  }
}
