import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/dashboard_models.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

class UpcomingSection extends StatelessWidget {
  const UpcomingSection({
    super.key,
    required this.items,
    required this.onOpenRoute,
  });

  final List<DashboardUpcomingItem> items;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upcoming', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: DashboardAppSpacing.md),
        for (final item in items) ...[
          AppCard(
            backgroundColor: tokens.surface,
            borderColor: tokens.border,
            borderRadius: DashboardAppRadii.lg,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: DashboardAppSpacing.xs),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: DashboardAppSpacing.xs),
                      Text(
                        '${item.subjectName}  ${_format(item.dateTime)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DashboardAppSpacing.sm),
                FilledButton(
                  onPressed: () => onOpenRoute(item.route),
                  child: Text(item.cta),
                ),
              ],
            ),
          ),
          if (item != items.last)
            const SizedBox(height: DashboardAppSpacing.md),
        ],
      ],
    );
  }

  String _format(DateTime? value) {
    if (value == null) {
      return 'TBD';
    }
    return DateFormat('EEE d MMM, h:mm a').format(value.toLocal());
  }
}
