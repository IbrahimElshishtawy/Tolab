import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'dashboard_section_primitives.dart';
import 'dashboard_view_helpers.dart';

class GroupActivityFeedSection extends StatelessWidget {
  const GroupActivityFeedSection({
    super.key,
    required this.feed,
    required this.onOpenRoute,
  });

  final DashboardGroupActivityFeed feed;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    if (feed.items.isEmpty) {
      return const DashboardSectionCard(
        title: 'Group Activity Feed',
        child: DashboardSectionEmpty(
          message: 'No recent posts, comments, or chat signals were found.',
        ),
      );
    }

    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Group Activity Feed',
      child: Column(
        children: feed.items
            .map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  dashboardIconForActivityType(item.activityType),
                  color: dashboardToneColor(tokens, 'secondary'),
                ),
                title: Text(
                  item.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: tokens.textPrimary),
                ),
                subtitle: Text(
                  '${item.authorName} • ${item.groupName} • ${dashboardRelativeTime(item.timestamp)}',
                  style: TextStyle(color: tokens.textSecondary),
                ),
                onTap: () => onOpenRoute(item.route),
              ),
            )
            .toList(),
      ),
    );
  }
}
