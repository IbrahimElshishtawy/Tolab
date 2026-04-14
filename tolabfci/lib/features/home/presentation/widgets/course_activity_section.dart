import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/home_dashboard.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
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
            title: 'نشاط المواد',
            subtitle: 'آخر ما تم رفعه أو فتحه داخل المواد الدراسية والمجموعة.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            const StudentSectionEmptyState(
              icon: Icons.auto_stories_outlined,
              title: 'لا يوجد نشاط حديث',
              message:
                  'ستظهر هنا المحاضرات الجديدة والكويزات والمنشورات فور إضافتها.',
            )
          else
            ...items.take(4).map((item) => _ActivityTile(item: item)),
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
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.goNamed(
        RouteNames.subjectDetails,
        pathParameters: {'subjectId': item.subjectId},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(_activityIcon(item.type), color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      AppBadge(
                        label: item.subjectName,
                        backgroundColor: Colors.white,
                        foregroundColor: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.createdAtLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
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
    case CourseActivityType.quiz:
      return Icons.quiz_outlined;
    case CourseActivityType.assignment:
      return Icons.assignment_outlined;
    case CourseActivityType.groupPost:
      return Icons.groups_outlined;
    case CourseActivityType.announcement:
      return Icons.campaign_outlined;
  }
}

Color _activityColor(CourseActivityType type) {
  switch (type) {
    case CourseActivityType.lecture:
      return AppColors.primary;
    case CourseActivityType.quiz:
      return AppColors.error;
    case CourseActivityType.assignment:
      return AppColors.warning;
    case CourseActivityType.groupPost:
      return AppColors.teal;
    case CourseActivityType.announcement:
      return AppColors.indigo;
  }
}
