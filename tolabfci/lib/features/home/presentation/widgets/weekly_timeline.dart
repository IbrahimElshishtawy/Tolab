import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import 'empty_states.dart';
import '../providers/home_providers.dart';

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
            title: 'Weekly timeline',
            subtitle: 'Everything coming up, grouped by when it matters.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (groups.isEmpty)
            const StudentSectionEmptyState(
              icon: Icons.event_available_outlined,
              title: 'No events lined up',
              message:
                  'Your lectures, quizzes, and tasks will appear here as soon as they are scheduled.',
            )
          else
            Column(
              children:
                  groups
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
        Text(group.title, style: Theme.of(context).textTheme.titleMedium),
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
    final color = _priorityColor(item.priority);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: item.target == null
          ? null
          : () => _openTarget(context, item.target!),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              item.timeLabel,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: color),
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
    case StudentTimelineKind.quiz:
      return Icons.edit_note_rounded;
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

void _openTarget(BuildContext context, StudentActionTarget target) {
  context.goNamed(target.routeName, pathParameters: target.pathParameters);
}
