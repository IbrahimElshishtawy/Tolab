import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

class StudentInsightsSection extends StatelessWidget {
  const StudentInsightsSection({super.key, required this.insights});

  final DashboardStudentInsights insights;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    final tiles = [
      _InsightTileData('Active today', insights.activeStudents, tokens.primary),
      _InsightTileData('Inactive', insights.inactiveStudents, tokens.warning),
      _InsightTileData(
        'Missing submissions',
        insights.missingSubmissions,
        tokens.danger,
      ),
      _InsightTileData('New comments', insights.newComments, tokens.secondary),
      _InsightTileData(
        'Unread messages',
        insights.unreadMessages,
        tokens.primary,
      ),
      _InsightTileData(
        'Low engagement',
        insights.lowEngagementCount,
        tokens.warning,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Student Insights', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: DashboardAppSpacing.md),
        Wrap(
          spacing: DashboardAppSpacing.md,
          runSpacing: DashboardAppSpacing.md,
          children: [
            for (final tile in tiles)
              SizedBox(
                width: 160,
                child: AppCard(
                  backgroundColor: tokens.surface,
                  borderColor: tokens.border,
                  borderRadius: DashboardAppRadii.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tile.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: DashboardAppSpacing.xs),
                      Text(
                        '${tile.value}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: tile.color,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (insights.needsAttention.isNotEmpty) ...[
          const SizedBox(height: DashboardAppSpacing.lg),
          Text(
            'Students Needing Attention',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: DashboardAppSpacing.sm),
          for (final student in insights.needsAttention)
            Padding(
              padding: const EdgeInsets.only(bottom: DashboardAppSpacing.sm),
              child: ListTile(
                tileColor: tokens.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DashboardAppRadii.lg),
                  side: BorderSide(color: tokens.border),
                ),
                title: Text(student.name),
                subtitle: Text(student.reason),
                leading: CircleAvatar(
                  backgroundColor: tokens.danger.withValues(alpha: 0.10),
                  child: Icon(
                    Icons.person_search_rounded,
                    color: tokens.danger,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _InsightTileData {
  const _InsightTileData(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}
