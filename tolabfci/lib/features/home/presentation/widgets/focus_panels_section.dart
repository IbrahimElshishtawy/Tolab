import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../providers/home_providers.dart';
import 'empty_states.dart';

class FocusPanelsSection extends StatelessWidget {
  const FocusPanelsSection({
    super.key,
    required this.quizzes,
    required this.tasks,
    required this.dailyTip,
  });

  final List<StudentUpcomingItem> quizzes;
  final List<StudentUpcomingItem> tasks;
  final String dailyTip;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'الكويزات والشيتات القريبة',
            subtitle: 'نظرة سريعة على أقرب ما ينتظرك خلال الأيام القادمة.',
          ),
          const SizedBox(height: AppSpacing.md),
          _UpcomingPanel(
            title: 'الكويزات القادمة',
            emptyTitle: 'لا توجد كويزات قريبة',
            items: quizzes,
          ),
          const SizedBox(height: AppSpacing.md),
          _UpcomingPanel(
            title: 'الشيتات القريبة',
            emptyTitle: 'لا توجد تسليمات عاجلة',
            items: tasks,
          ),
          const SizedBox(height: AppSpacing.md),
          _DailyTipCard(tip: dailyTip),
        ],
      ),
    );
  }
}

class _UpcomingPanel extends StatelessWidget {
  const _UpcomingPanel({
    required this.title,
    required this.emptyTitle,
    required this.items,
  });

  final String title;
  final String emptyTitle;
  final List<StudentUpcomingItem> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          if (items.isEmpty)
            StudentSectionEmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: emptyTitle,
              message: 'سيظهر هنا أي تحديث جديد فور إضافته.',
            )
          else
            ...items.map((item) => _UpcomingTile(item: item)),
        ],
      ),
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.item});

  final StudentUpcomingItem item;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final color = item.kind == StudentUpcomingKind.quiz
        ? AppColors.indigo
        : AppColors.warning;

    return InkWell(
      onTap: () => context.goNamed(
        item.target.routeName,
        pathParameters: item.target.pathParameters,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                item.kind == StudentUpcomingKind.quiz
                    ? Icons.quiz_outlined
                    : Icons.assignment_outlined,
                color: color,
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
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.meta, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.auxiliary,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نصيحة أكاديمية اليوم',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(tip, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
