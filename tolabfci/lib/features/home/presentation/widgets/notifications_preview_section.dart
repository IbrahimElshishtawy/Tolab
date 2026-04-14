import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/notification_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import 'empty_states.dart';

class NotificationsPreviewSection extends StatelessWidget {
  const NotificationsPreviewSection({
    super.key,
    required this.items,
    required this.unreadCount,
  });

  final List<AppNotificationItem> items;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'آخر التنبيهات',
            subtitle: 'أحدث 3 تنبيهات مرتبطة بموادك ومهامك الحالية.',
            trailing: AppBadge(
              label: unreadCount == 0 ? 'مقروءة' : '$unreadCount غير مقروء',
              backgroundColor: unreadCount == 0 ? AppColors.surfaceAlt : AppColors.primarySoft,
              foregroundColor: unreadCount == 0 ? AppColors.textSecondary : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            const StudentSectionEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'لا توجد تنبيهات جديدة',
              message: 'ستظهر هنا تحديثات المحاضرات والكويزات والدرجات أولاً بأول.',
            )
          else
            ...items.map((item) => _NotificationTile(item: item)),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final AppNotificationItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.goNamed(
        item.routeName,
        pathParameters: item.pathParameters,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.surfaceAlt : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isImportant
                ? AppColors.error.withValues(alpha: 0.20)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppBadge(
                  label: item.category,
                  backgroundColor: Colors.white,
                  foregroundColor: item.isImportant ? AppColors.error : AppColors.primary,
                ),
                const Spacer(),
                Text(item.createdAtLabel, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(item.body, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
