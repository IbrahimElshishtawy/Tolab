import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/dashboard_theme_tokens.dart';

class TodayStatsSection extends StatelessWidget {
  const TodayStatsSection({
    super.key,
    required this.stats,
    required this.onOpenRoute,
  });

  final DashboardTodayStats stats;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final items = [
      _TodayStatCardData(
        label: 'Upcoming Lectures',
        value: stats.lectures,
        route: '/workspace/schedule',
        icon: Icons.slideshow_rounded,
      ),
      _TodayStatCardData(
        label: 'Sections',
        value: stats.sections,
        route: '/workspace/schedule',
        icon: Icons.widgets_rounded,
      ),
      _TodayStatCardData(
        label: 'Quizzes',
        value: stats.quizzes,
        route: '/workspace/quizzes',
        icon: Icons.quiz_rounded,
      ),
      _TodayStatCardData(
        label: 'Tasks',
        value: stats.tasks,
        route: '/workspace/tasks',
        icon: Icons.assignment_rounded,
      ),
    ];
    final tokens = DashboardThemeTokens.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : 2;
        final width =
            (constraints.maxWidth - ((columns - 1) * DashboardAppSpacing.md)) /
            columns;

        return Wrap(
          spacing: DashboardAppSpacing.md,
          runSpacing: DashboardAppSpacing.md,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: AppCard(
                  interactive: true,
                  onTap: () => onOpenRoute(item.route),
                  backgroundColor: tokens.surface,
                  borderColor: tokens.border,
                  borderRadius: DashboardAppRadii.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, color: tokens.primary),
                      const SizedBox(height: DashboardAppSpacing.sm),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: DashboardAppSpacing.xs),
                      Text(
                        '${item.value}',
                        style: DashboardAppTypography.metric(context),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TodayStatCardData {
  const _TodayStatCardData({
    required this.label,
    required this.value,
    required this.route,
    required this.icon,
  });

  final String label;
  final int value;
  final String route;
  final IconData icon;
}
