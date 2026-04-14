import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../providers/home_providers.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key, required this.actions});

  final List<StudentQuickActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Quick actions',
            subtitle: 'Jump straight into the next thing you need.',
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < actions.length; index++) ...[
                  _QuickActionTile(action: actions[index]),
                  if (index != actions.length - 1)
                    const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final StudentQuickActionItem action;

  @override
  Widget build(BuildContext context) {
    final spec = _QuickActionSpec.fromType(action.type);
    final enabled = action.isEnabled;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? () => _openTarget(context, action.target!) : null,
      child: Ink(
        width: 122,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primarySoft : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: enabled ? Colors.white : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                spec.icon,
                color: enabled ? spec.color : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(spec.label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              action.helperText ?? spec.helperText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionSpec {
  const _QuickActionSpec({
    required this.label,
    required this.helperText,
    required this.icon,
    required this.color,
  });

  factory _QuickActionSpec.fromType(StudentQuickActionType type) {
    switch (type) {
      case StudentQuickActionType.joinLecture:
        return const _QuickActionSpec(
          label: 'Join Lecture',
          helperText: 'Open the next live session',
          icon: Icons.play_circle_outline_rounded,
          color: AppColors.primary,
        );
      case StudentQuickActionType.openQuiz:
        return const _QuickActionSpec(
          label: 'Open Quiz',
          helperText: 'Start your active quiz',
          icon: Icons.edit_note_rounded,
          color: AppColors.error,
        );
      case StudentQuickActionType.viewSchedule:
        return const _QuickActionSpec(
          label: 'View Schedule',
          helperText: 'Check what is coming next',
          icon: Icons.calendar_today_outlined,
          color: AppColors.indigo,
        );
      case StudentQuickActionType.openCourse:
        return const _QuickActionSpec(
          label: 'Open Course',
          helperText: 'Continue your current course',
          icon: Icons.menu_book_outlined,
          color: AppColors.teal,
        );
      case StudentQuickActionType.checkResults:
        return const _QuickActionSpec(
          label: 'Check Results',
          helperText: 'Review grades and performance',
          icon: Icons.insights_outlined,
          color: AppColors.success,
        );
    }
  }

  final String label;
  final String helperText;
  final IconData icon;
  final Color color;
}

void _openTarget(BuildContext context, StudentActionTarget target) {
  context.goNamed(target.routeName, pathParameters: target.pathParameters);
}
