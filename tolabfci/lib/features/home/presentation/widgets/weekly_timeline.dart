import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../providers/home_providers.dart';
import 'empty_states.dart';

class WeeklyTimeline extends StatelessWidget {
  const WeeklyTimeline({super.key, required this.groups});

  final List<StudentTimelineGroup> groups;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'جدول اليوم والأسبوع',
            subtitle: 'محاضرات وسكاشن وكويزات وتسليمات مجمعة حسب الأقرب.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (groups.isEmpty)
            const StudentSectionEmptyState(
              icon: Icons.event_available_outlined,
              title: 'لا توجد أحداث قادمة',
              message: 'سيظهر هنا جدولك اليومي والأسبوعي فور توفر مواعيد جديدة.',
            )
          else
            Column(
              children: groups
                  .map((group) => _TimelineGroup(group: group))
                  .expand(
                    (widget) => [
                      widget,
                      const SizedBox(height: AppSpacing.md),
                    ],
                  )
                  .toList()
                ..removeLast(),
            ),
        ],
      ),
    );
  }
}

class _TimelineGroup extends StatelessWidget {
  const _TimelineGroup({required this.group});

  final StudentTimelineGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        ...group.items.map((item) => _TimelineTile(item: item)),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.item});

  final StudentTimelineItem item;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final color = _priorityColor(item.priority);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: item.target == null
          ? null
          : () => context.goNamed(
                item.target!.routeName,
                pathParameters: item.target!.pathParameters,
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(_kindIcon(item.kind), color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              item.timeLabel,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _kindIcon(StudentTimelineKind kind) {
  switch (kind) {
    case StudentTimelineKind.lecture:
      return Icons.play_circle_outline_rounded;
    case StudentTimelineKind.section:
      return Icons.co_present_outlined;
    case StudentTimelineKind.quiz:
      return Icons.quiz_outlined;
    case StudentTimelineKind.task:
      return Icons.assignment_outlined;
  }
}

Color _priorityColor(StudentPriority priority) {
  switch (priority) {
    case StudentPriority.urgent:
      return AppColors.error;
    case StudentPriority.soon:
      return AppColors.warning;
    case StudentPriority.safe:
      return AppColors.success;
  }
}
