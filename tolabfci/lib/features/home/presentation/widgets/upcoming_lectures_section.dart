import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import 'empty_states.dart';
import '../providers/home_providers.dart';

class UpcomingLecturesSection extends StatelessWidget {
  const UpcomingLecturesSection({super.key, required this.items});

  final List<StudentLectureCardModel> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Upcoming lectures',
            subtitle:
                'Your next live sessions, with the nearest one highlighted.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            const StudentSectionEmptyState(
              icon: Icons.play_circle_outline_rounded,
              title: 'No lectures yet',
              message:
                  'Once lectures are scheduled, you will be able to join them from here.',
            )
          else
            ...items.map((item) => _LectureTile(item: item)),
        ],
      ),
    );
  }
}

class _LectureTile extends StatelessWidget {
  const _LectureTile({required this.item});

  final StudentLectureCardModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: item.isNext ? AppColors.primarySoft : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isNext
              ? AppColors.primary.withValues(alpha: 0.18)
              : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              item.lecture.isOnline
                  ? Icons.videocam_outlined
                  : Icons.location_on_outlined,
              color: item.lecture.isOnline ? AppColors.primary : AppColors.teal,
            ),
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
                        item.lecture.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.isNext)
                      const AppBadge(
                        label: 'Next',
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.lecture.subjectName ?? 'Lecture',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${item.timeLabel} • ${item.statusLabel}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton.tonal(
            onPressed: () => _openTarget(context, item.target),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

void _openTarget(BuildContext context, StudentActionTarget target) {
  context.goNamed(target.routeName, pathParameters: target.pathParameters);
}
