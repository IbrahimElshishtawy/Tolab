import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

class TodayScheduleSection extends StatelessWidget {
  const TodayScheduleSection({
    super.key,
    required this.items,
    required this.onOpenRoute,
  });

  final List<DashboardScheduleItem> items;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today Schedule', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: DashboardAppSpacing.sm),
        Text(
          'Your timeline for lectures, sections, quizzes, and delivery blocks.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: DashboardAppSpacing.md),
        if (items.isEmpty)
          Text(
            'No scheduled items for today.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        for (final item in items) ...[
          AppCard(
            interactive: true,
            onTap: () => onOpenRoute(item.route),
            backgroundColor: tokens.surface,
            borderColor: tokens.border,
            borderRadius: DashboardAppRadii.lg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tokens.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DashboardAppRadii.md),
                  ),
                  child: Icon(_icon(item.type), color: tokens.primary),
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
                        '${item.subjectName}  ${item.time}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: DashboardAppSpacing.xs),
                      Text(
                        '${item.location}  ${item.status}',
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
          if (item != items.last)
            const SizedBox(height: DashboardAppSpacing.md),
        ],
      ],
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'SECTION':
        return Icons.science_rounded;
      case 'QUIZ':
        return Icons.quiz_rounded;
      case 'TASK':
      case 'TASK_DUE':
        return Icons.assignment_rounded;
      default:
        return Icons.slideshow_rounded;
    }
  }
}
