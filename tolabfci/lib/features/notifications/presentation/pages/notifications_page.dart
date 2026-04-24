import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../staff_portal/presentation/pages/staff_notifications_page.dart';
import '../../../../core/models/notification_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/repositories/mock_notifications_repository.dart';
import '../providers/notifications_providers.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _filter = 'الكل';
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final isStaff = ref.watch(isStaffUserProvider);
    if (isStaff) {
      return const StaffNotificationsPage();
    }

    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: notificationsAsync.when(
          data: (notifications) {
            final filtered =
                notifications
                    .where(
                      (item) => _filter == 'الكل' || item.category == _filter,
                    )
                    .where((item) => !_unreadOnly || !item.isRead)
                    .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
                        'التنبيهات',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'تنبيهات أكاديمية قابلة للاستخدام الفعلي، مع تصفية سريعة، unread only، ووصول مباشر للعنصر المرتبط.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final filter in const [
                            'الكل',
                            'أكاديمي',
                            'كويزات',
                            'شيتات',
                            'درجات',
                            'الجروب',
                          ])
                            ChoiceChip(
                              label: Text(filter),
                              selected: _filter == filter,
                              onSelected: (_) =>
                                  setState(() => _filter = filter),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('غير المقروء فقط'),
                        value: _unreadOnly,
                        onChanged: (value) =>
                            setState(() => _unreadOnly = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    title: 'لا توجد تنبيهات ضمن هذا العرض',
                    subtitle:
                        'غيّر الفلاتر أو أوقف unread only لعرض المزيد من التحديثات.',
                  )
                else ...[
                  if (todayItems.isNotEmpty)
                    _NotificationGroup(
                      title: 'اليوم',
                      items: todayItems,
                      onOpen: _openNotification,
                    ),
                  if (weekItems.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _NotificationGroup(
                      title: 'هذا الأسبوع',
                      items: weekItems,
                      onOpen: _openNotification,
                    ),
                  ],
                  if (olderItems.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _NotificationGroup(
                      title: 'أقدم',
                      items: olderItems,
                      onOpen: _openNotification,
                    ),
                  ],
                ],
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'جارٍ تحميل التنبيهات...'),
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

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({
    required this.title,
    required this.items,
    required this.onOpen,
  });

  final String title;
  final List<AppNotificationItem> items;
  final Future<void> Function(BuildContext context, AppNotificationItem item)
  onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onOpen(context, item),
              child: _NotificationCard(item: item),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final AppNotificationItem item;

  @override
  Widget build(BuildContext context) {
    final accent = _urgencyColor(item.urgency);
    final palette = context.appColors;

    return AppCard(
      backgroundColor: item.isRead ? palette.surface : palette.surfaceElevated,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 70,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppBadge(
                      label: item.category,
                      backgroundColor: palette.surfaceAlt,
                      foregroundColor: accent,
                    ),
                    AppBadge(
                      label: _urgencyLabel(item.urgency),
                      backgroundColor: accent.withValues(alpha: 0.12),
                      foregroundColor: accent,
                    ),
                    if (item.subjectName != null)
                      AppBadge(
                        label: item.subjectName!,
                        backgroundColor: Colors.white,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(item.body, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      item.createdAtLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const Spacer(),
                    if (!item.isRead)
                      Text(
                        'جديد',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _urgencyLabel(NotificationUrgency urgency) {
  return switch (urgency) {
    NotificationUrgency.newItem => 'جديد',
    NotificationUrgency.important => 'مهم',
    NotificationUrgency.urgent => 'عاجل',
  };
}

Color _urgencyColor(NotificationUrgency urgency) {
  return switch (urgency) {
    NotificationUrgency.newItem => AppColors.primary,
    NotificationUrgency.important => AppColors.warning,
    NotificationUrgency.urgent => AppColors.error,
  };
}
