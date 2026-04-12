import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'group_activity_card.dart';

class GroupActivitySection extends StatelessWidget {
  const GroupActivitySection({
    super.key,
    required this.items,
    required this.onOpenRoute,
  });

  final List<DashboardGroupActivityItem> items;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Group Activity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: DashboardAppSpacing.sm),
        Text(
          'Recent group discussions so you can monitor student momentum fast.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: DashboardAppSpacing.md),
        for (final item in items) ...[
          GroupActivityCard(item: item, onOpenRoute: onOpenRoute),
          if (item != items.last)
            const SizedBox(height: DashboardAppSpacing.md),
        ],
      ],
    );
  }
}
