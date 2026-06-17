import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/models/notification_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
  });

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
            width: 8,
            height: 64,
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
                      label: _urgencyLabel(context, item.urgency),
                      backgroundColor: accent.withValues(alpha: 0.12),
                      foregroundColor: accent,
                    ),
                    if (item.subjectName != null)
                      AppBadge(
                        label: item.subjectName!,
                        backgroundColor: palette.surfaceAlt,
                        foregroundColor: palette.textPrimary,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.body,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
                        context.tr('جديد', 'New'),
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

  String _urgencyLabel(BuildContext context, NotificationUrgency urgency) {
    return switch (urgency) {
      NotificationUrgency.newItem => context.tr('جديد', 'New'),
      NotificationUrgency.important => context.tr('مهم', 'Important'),
      NotificationUrgency.urgent => context.tr('عاجل', 'Urgent'),
    };
  }

  Color _urgencyColor(NotificationUrgency urgency) {
    return switch (urgency) {
      NotificationUrgency.newItem => AppColors.primary,
      NotificationUrgency.important => AppColors.warning,
      NotificationUrgency.urgent => AppColors.error,
    };
  }
}
