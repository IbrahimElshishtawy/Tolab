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
import '../../../../core/widgets/app_section_header.dart';
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
            final filtered = notifications.where((item) {
              if (_filter == 'الكل') {
                return true;
              }
              return item.category == _filter;
            }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            final today = DateTime.now();
            final todayStart = DateTime(today.year, today.month, today.day);
            final weekStart = todayStart.subtract(
              Duration(days: today.weekday - 1),
            );

            final todayItems = filtered
                .where((item) => item.createdAt.isAfter(todayStart))
                .toList();
            final weekItems = filtered
                .where(
                  (item) =>
                      item.createdAt.isAfter(weekStart) &&
                      item.createdAt.isBefore(todayStart),
                )
                .toList();
            final olderItems = filtered
                .where((item) => item.createdAt.isBefore(weekStart))
                .toList();

            return ListView(
              children: [
                const AppSectionHeader(
                  title: 'التنبيهات',
                  subtitle:
                      'تنبيهات أكاديمية وكويزات وشيتات ودرجات مع وصول مباشر.',
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children:
                      ['الكل', 'أكاديمي', 'كويزات', 'شيتات', 'درجات', 'عام']
                          .map(
                            (filter) => ChoiceChip(
                              label: Text(filter),
                              selected: _filter == filter,
                              onSelected: (_) =>
                                  setState(() => _filter = filter),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    title: 'لا توجد تنبيهات',
                    subtitle: 'ستظهر التحديثات الأكاديمية هنا بمجرد وصولها.',
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
          loading: () => const LoadingWidget(label: 'جاري تحميل التنبيهات...'),
          error: (error, stackTrace) =>
              ErrorStateWidget(message: error.toString()),
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
        const SizedBox(height: AppSpacing.sm),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
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
    final palette = context.appColors;
    final priorityColor = item.isImportant
        ? AppColors.error
        : AppColors.primary;

    return AppCard(
      backgroundColor: item.isRead ? palette.surface : palette.surfaceElevated,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: item.isRead ? palette.border : priorityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppBadge(
                      label: item.category,
                      backgroundColor: palette.surfaceAlt,
                      foregroundColor: priorityColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (item.isImportant)
                      AppBadge(
                        label: 'مهم',
                        backgroundColor: palette.errorSoft,
                        foregroundColor: AppColors.error,
                      ),
                    const Spacer(),
                    Text(
                      item.createdAtLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(item.body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
