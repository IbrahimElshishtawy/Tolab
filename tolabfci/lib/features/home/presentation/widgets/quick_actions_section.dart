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
            title: 'إجراءات سريعة',
            subtitle:
                'اختصارات مباشرة لأكثر الأدوات استخدامًا خلال يومك الدراسي.',
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
    final palette = context.appColors;
    final spec = _QuickActionSpec.fromType(action.type);
    final enabled = action.isEnabled;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: enabled
          ? () => context.goNamed(
              action.target!.routeName,
              pathParameters: action.target!.pathParameters,
            )
          : null,
      child: Ink(
        width: 148,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: enabled
              ? spec.color.withValues(alpha: 0.10)
              : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: enabled
                ? spec.color.withValues(alpha: 0.20)
                : palette.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                spec.icon,
                color: enabled ? spec.color : palette.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(spec.label, style: Theme.of(context).textTheme.bodyMedium),
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
      case StudentQuickActionType.viewTimetable:
        return const _QuickActionSpec(
          label: 'عرض الجدول',
          helperText: 'اليوم وغدًا',
          icon: Icons.calendar_month_outlined,
          color: AppColors.primary,
        );
      case StudentQuickActionType.openQuiz:
        return const _QuickActionSpec(
          label: 'دخول الكويز',
          helperText: 'ابدئي الكويز الحالي',
          icon: Icons.quiz_outlined,
          color: AppColors.error,
        );
      case StudentQuickActionType.uploadAssignment:
        return const _QuickActionSpec(
          label: 'رفع الشيت',
          helperText: 'ارفعي الحل بسرعة',
          icon: Icons.upload_file_outlined,
          color: AppColors.warning,
        );
      case StudentQuickActionType.openCourse:
        return const _QuickActionSpec(
          label: 'فتح المادة',
          helperText: 'اذهبي لمساحة المادة',
          icon: Icons.menu_book_outlined,
          color: AppColors.teal,
        );
      case StudentQuickActionType.checkResults:
        return const _QuickActionSpec(
          label: 'عرض النتائج',
          helperText: 'تابعي تقدمك',
          icon: Icons.insights_outlined,
          color: AppColors.success,
        );
      case StudentQuickActionType.latestAnnouncement:
        return const _QuickActionSpec(
          label: 'آخر إعلان',
          helperText: 'الإعلانات الرسمية',
          icon: Icons.campaign_outlined,
          color: AppColors.support,
        );
    }
  }

  final String label;
  final String helperText;
  final IconData icon;
  final Color color;
}
