import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/moderation_models.dart';
import '../../state/models/moderation_state_models.dart';

class ModerationOverviewStrip extends StatelessWidget {
  const ModerationOverviewStrip({
    super.key,
    required this.metrics,
    required this.notifications,
  });

  final ModerationMetrics metrics;
  final List<ModerationNotificationItem> notifications;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1100;
        final metricsRow = Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _MetricCard(
              label: 'Open reports',
              value: metrics.openReports.toString(),
              color: AppColors.warning,
              icon: Icons.flag_outlined,
            ),
            _MetricCard(
              label: 'Flagged messages',
              value: metrics.flaggedMessages.toString(),
              color: AppColors.danger,
              icon: Icons.mark_chat_unread_outlined,
            ),
            _MetricCard(
              label: 'Restricted groups',
              value: metrics.restrictedGroups.toString(),
              color: AppColors.info,
              icon: Icons.groups_rounded,
            ),
            _MetricCard(
              label: 'Pending actions',
              value: metrics.pendingActions.toString(),
              color: AppColors.primary,
              icon: Icons.rule_rounded,
            ),
          ],
        );

        final panel = _NotificationsPanel(notifications: notifications);
        if (compact) {
          return Column(
            children: [
              metricsRow,
              const SizedBox(height: AppSpacing.md),
              panel,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: metricsRow),
            const SizedBox(width: AppSpacing.md),
            Expanded(flex: 4, child: panel),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 196,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              StatusBadge(label == 'Open reports' ? 'Live' : 'Trend'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _NotificationsPanel extends StatelessWidget {
  const _NotificationsPanel({required this.notifications});

  final List<ModerationNotificationItem> notifications;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'New reports',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusBadge('${notifications.where((item) => item.isUnread).length} new'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (notifications.isEmpty)
            Text(
              'No new moderation alerts right now.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            ...notifications.map(
              (notification) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          color: notification.isUnread
                              ? AppColors.danger
                              : AppColors.slate,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              notification.subtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormat('HH:mm').format(notification.createdAt),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
