import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/home_dashboard.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import 'empty_states.dart';

class CourseActivitySection extends StatelessWidget {
  const CourseActivitySection({super.key, required this.items});

  final List<CourseActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Course activity',
            subtitle:
                'Recent updates from your courses so nothing important stays buried.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            const StudentSectionEmptyState(
              icon: Icons.auto_stories_outlined,
              title: 'No recent course activity',
              message:
                  'New uploads, tasks, and announcements will appear here.',
            )
          else
            ...items.take(3).map((item) => _ActivityTile(item: item)),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});

  final CourseActivityItem item;

  @override
  Widget build(BuildContext context) {
    final color = _activityColor(item.type);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.goNamed(
        RouteNames.subjectDetails,
        pathParameters: {'subjectId': item.subjectId},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(_activityIcon(item.type), color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.subjectName,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              item.createdAtLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

IconData _activityIcon(CourseActivityType type) {
  switch (type) {
    case CourseActivityType.lecture:
      return Icons.play_lesson_outlined;
    case CourseActivityType.task:
      return Icons.assignment_outlined;
    case CourseActivityType.announcement:
      return Icons.campaign_outlined;
  }
}

Color _activityColor(CourseActivityType type) {
  switch (type) {
    case CourseActivityType.lecture:
      return AppColors.primary;
    case CourseActivityType.task:
      return AppColors.warning;
    case CourseActivityType.announcement:
      return AppColors.teal;
  }
}
