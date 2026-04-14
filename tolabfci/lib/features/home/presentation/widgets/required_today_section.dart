import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../providers/home_providers.dart';

class RequiredTodaySection extends StatelessWidget {
  const RequiredTodaySection({super.key, required this.items});

  final List<StudentRequiredActionItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'المطلوب منك اليوم',
            subtitle: 'أهم ما يحتاج انتباهك الآن بشكل واضح وسريع.',
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            children: items
                .map((item) => _RequiredActionTile(item: item))
                .expand(
                  (widget) => [
                    widget,
                    const SizedBox(height: AppSpacing.sm),
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

class _RequiredActionTile extends StatelessWidget {
  const _RequiredActionTile({required this.item});

  final StudentRequiredActionItem item;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final color = switch (item.priority) {
      StudentPriority.urgent => AppColors.error,
      StudentPriority.soon => AppColors.warning,
      StudentPriority.safe => AppColors.success,
    };
    final softColor = switch (item.priority) {
      StudentPriority.urgent => palette.errorSoft,
      StudentPriority.soon => palette.warningSoft,
      StudentPriority.safe => palette.successSoft,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.meta,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton.tonal(
            onPressed: item.target == null
                ? null
                : () => context.goNamed(
                      item.target!.routeName,
                      pathParameters: item.target!.pathParameters,
                    ),
            child: Text(item.ctaLabel),
          ),
        ],
      ),
    );
  }
}
