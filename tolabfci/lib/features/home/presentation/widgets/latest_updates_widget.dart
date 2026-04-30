import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/models/notification_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class LatestUpdatesWidget extends StatelessWidget {
  const LatestUpdatesWidget({
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
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('آخر التحديثات', 'Latest updates'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              AppBadge(
                label: unreadCount == 0
                    ? context.tr('مقروءة', 'Read')
                    : context.tr('$unreadCount جديد', '$unreadCount new'),
                backgroundColor: unreadCount == 0
                    ? context.appColors.surfaceAlt
                    : context.appColors.primarySoft,
                foregroundColor: unreadCount == 0
                    ? context.appColors.textSecondary
                    : AppColors.primary,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            _EmptyUpdatesState()
          else
            ...items.take(5).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _LatestUpdateTile(item: item),
                  ),
                ),
        ],
      ),
    );
  }
}

class _LatestUpdateTile extends StatelessWidget {
  const _LatestUpdateTile({required this.item});

  final AppNotificationItem item;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(item);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () =>
          context.goNamed(item.routeName, pathParameters: item.pathParameters),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: item.isRead ? 0.06 : 0.11),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.16)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(_iconFor(item), color: accent, size: 21),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.subjectName ?? item.category,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(item.createdAtLabel),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              label: context.tr('فتح', 'Open'),
              onPressed: () => context.goNamed(
                item.routeName,
                pathParameters: item.pathParameters,
              ),
              icon: Icons.arrow_forward_rounded,
              isExpanded: false,
              variant: AppButtonVariant.ghost,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyUpdatesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.tr('لا توجد تحديثات جديدة', 'No new updates'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

Color _accentFor(AppNotificationItem item) {
  return switch (item.urgency) {
    NotificationUrgency.urgent => AppColors.error,
    NotificationUrgency.important => AppColors.warning,
    NotificationUrgency.newItem => _categoryColor(item.category),
  };
}

Color _categoryColor(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('quiz') || category.contains('كويز')) {
    return AppColors.error;
  }
  if (normalized.contains('task') || category.contains('شيت')) {
    return AppColors.warning;
  }
  if (normalized.contains('group') || category.contains('مجتمع')) {
    return AppColors.indigo;
  }
  if (normalized.contains('lecture') || category.contains('محاضرة')) {
    return AppColors.primary;
  }
  return AppColors.success;
}

IconData _iconFor(AppNotificationItem item) {
  final category = item.category.toLowerCase();
  if (category.contains('quiz') || item.category.contains('كويز')) {
    return Icons.quiz_outlined;
  }
  if (category.contains('task') || item.category.contains('شيت')) {
    return Icons.assignment_outlined;
  }
  if (category.contains('group') || item.category.contains('مجتمع')) {
    return Icons.groups_2_outlined;
  }
  if (category.contains('lecture') || item.category.contains('محاضرة')) {
    return Icons.play_lesson_outlined;
  }
  return Icons.campaign_outlined;
}
