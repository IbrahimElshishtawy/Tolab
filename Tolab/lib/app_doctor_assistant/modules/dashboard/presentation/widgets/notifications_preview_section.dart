import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/dashboard_models.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

class NotificationsPreviewSection extends StatelessWidget {
  const NotificationsPreviewSection({
    super.key,
    required this.notifications,
    required this.onOpenRoute,
  });

  final DashboardNotificationsSummary notifications;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Notifications Preview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: () => onOpenRoute('/workspace/notifications'),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: DashboardAppSpacing.md),
        for (final item in notifications.latest) ...[
          AppCard(
            interactive: true,
            onTap: () => onOpenRoute(item.route),
            backgroundColor: tokens.surface,
            borderColor: item.isUnread
                ? tokens.primary.withValues(alpha: 0.28)
                : tokens.border,
            borderRadius: DashboardAppRadii.lg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      (item.isUnread ? tokens.primary : tokens.secondary)
                          .withValues(alpha: 0.12),
                  child: Icon(
                    item.isUnread
                        ? Icons.mark_email_unread_rounded
                        : Icons.mark_email_read_rounded,
                    color: item.isUnread ? tokens.primary : tokens.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: DashboardAppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: DashboardAppSpacing.xs),
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: DashboardAppSpacing.xs),
                      Text(
                        _format(item.time),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (item != notifications.latest.last)
            const SizedBox(height: DashboardAppSpacing.md),
        ],
      ],
    );
  }

  String _format(DateTime? value) {
    if (value == null) {
      return 'Just now';
    }
    return DateFormat('d MMM, h:mm a').format(value.toLocal());
  }
}
