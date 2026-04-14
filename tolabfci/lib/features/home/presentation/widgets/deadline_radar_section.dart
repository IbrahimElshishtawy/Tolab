import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import 'empty_states.dart';
import '../providers/home_providers.dart';

class DeadlineRadarSection extends StatelessWidget {
  const DeadlineRadarSection({super.key, required this.items});

  final List<StudentDeadlineItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Deadline radar',
            subtitle:
                'Urgent items float to the top so you can act before they slip.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            const StudentSectionEmptyState(
              icon: Icons.radar_outlined,
              title: 'No urgent deadlines',
              message:
                  'You are caught up right now. New deadlines will be ranked here by priority.',
            )
          else
            ...items.map((item) => _DeadlineTile(item: item)),
        ],
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  const _DeadlineTile({required this.item});

  final StudentDeadlineItem item;

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
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
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
              item.meta,
              textAlign: TextAlign.end,
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
