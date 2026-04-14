import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'dashboard_section_primitives.dart';
import 'dashboard_view_helpers.dart';

class NotificationsPreviewSection extends StatelessWidget {
  const NotificationsPreviewSection({
    super.key,
    required this.section,
    required this.onOpenRoute,
  });

  final DashboardNotificationsPreview section;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) {
      return DashboardSectionCard(
        title: 'Notifications Preview',
        child: DashboardSectionEmpty(
          message: section.unreadCount == 0
              ? 'Notifications are clear.'
              : 'Unread notifications exist, but preview content is empty.',
        ),
      );
    }

    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Notifications Preview',
      subtitle: '${section.unreadCount} unread notifications.',
      child: Column(
        children: section.items
            .map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  item.isUnread
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: item.isUnread ? tokens.warning : tokens.secondary,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(color: tokens.textPrimary),
                ),
                subtitle: Text(
                  '${item.body} • ${dashboardRelativeTime(item.time)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: tokens.textSecondary),
                ),
                trailing: DashboardToneBadge(
                  label: item.category,
                  tone: item.isUnread ? 'warning' : 'secondary',
                ),
                onTap: () => onOpenRoute(item.route),
              ),
            )
            .toList(),
      ),
    );
  }
}
