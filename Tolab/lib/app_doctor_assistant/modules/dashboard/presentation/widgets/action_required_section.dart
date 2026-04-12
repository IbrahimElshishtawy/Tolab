import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'action_required_card.dart';

class ActionRequiredSection extends StatelessWidget {
  const ActionRequiredSection({
    super.key,
    required this.items,
    required this.onOpenRoute,
  });

  final List<DashboardActionRequiredItem> items;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Action Required', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: DashboardAppSpacing.sm),
        Text(
          'This is the priority queue for what needs intervention next.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: DashboardAppSpacing.md),
        if (items.isEmpty)
          Text(
            'No urgent blockers right now.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        for (final item in items) ...[
          ActionRequiredCard(item: item, onOpenRoute: onOpenRoute),
          if (item != items.last)
            const SizedBox(height: DashboardAppSpacing.md),
        ],
      ],
    );
  }
}
