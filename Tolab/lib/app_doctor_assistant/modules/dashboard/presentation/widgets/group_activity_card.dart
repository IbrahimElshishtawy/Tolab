import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/dashboard_models.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

class GroupActivityCard extends StatelessWidget {
  const GroupActivityCard({
    super.key,
    required this.item,
    required this.onOpenRoute,
  });

  final DashboardGroupActivityItem item;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return AppCard(
      interactive: true,
      onTap: () => onOpenRoute(item.route),
      backgroundColor: tokens.surface,
      borderColor: tokens.border,
      borderRadius: DashboardAppRadii.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.activityType,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: DashboardAppSpacing.xs),
          Text(
            item.subjectName ?? item.groupName ?? 'Group activity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: DashboardAppSpacing.xs),
          Text(
            item.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: DashboardAppSpacing.xs),
          Text(
            '${item.authorName ?? 'Student'}  ${_format(item.timestamp)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }

  String _format(DateTime? value) {
    if (value == null) {
      return 'Just now';
    }
    return DateFormat('d MMM, h:mm a').format(value.toLocal());
  }
}
