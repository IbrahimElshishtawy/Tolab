import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../design/departments_management_tokens.dart';

String formatCompactNumber(int value) {
  return NumberFormat.compact().format(value);
}

String formatPercent(double value) {
  return '${value.toStringAsFixed(value >= 100 ? 0 : 1)}%';
}

Color departmentToneColor(String tone) => switch (tone.toLowerCase()) {
  'good' || 'strong' => DepartmentsManagementTokens.mint,
  'attention' => DepartmentsManagementTokens.amber,
  'critical' => DepartmentsManagementTokens.rose,
  _ => DepartmentsManagementTokens.accent,
};

class DepartmentStatTile extends StatelessWidget {
  const DepartmentStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.footer,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppConstants.mediumRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(footer!, style: Theme.of(context).textTheme.labelMedium),
          ],
        ],
      ),
    );
  }
}

class DepartmentAvatar extends StatelessWidget {
  const DepartmentAvatar({
    super.key,
    required this.imageUrl,
    required this.fallback,
    this.radius = 22,
  });

  final String imageUrl;
  final String fallback;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: DepartmentsManagementTokens.accentSoft,
        child: Text(
          fallback.characters.first.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: DepartmentsManagementTokens.accent,
          ),
        ),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: DepartmentsManagementTokens.accentSoft,
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: radius,
          backgroundColor: DepartmentsManagementTokens.accentSoft,
          child: Text(
            fallback.characters.first.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: DepartmentsManagementTokens.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class DepartmentPanelHeader extends StatelessWidget {
  const DepartmentPanelHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}

class DepartmentActivityTimeline extends StatelessWidget {
  const DepartmentActivityTimeline({super.key, required this.items});

  final List<(String title, String subtitle, String time, String tone)> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == items.length - 1 ? 0 : AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: departmentToneColor(items[index].$4),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    if (index != items.length - 1)
                      Container(
                        width: 1,
                        height: 46,
                        color: Theme.of(context).dividerColor,
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[index].$1,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[index].$2,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        items[index].$3,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class DepartmentChip extends StatelessWidget {
  const DepartmentChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? DepartmentsManagementTokens.accent
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? DepartmentsManagementTokens.accent
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}

class DepartmentStatusPill extends StatelessWidget {
  const DepartmentStatusPill({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(label, icon: icon);
  }
}
