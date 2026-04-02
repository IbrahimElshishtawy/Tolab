import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/section_management_models.dart';
import '../design/section_management_tokens.dart';

class SectionGlassPanel extends StatelessWidget {
  const SectionGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: SectionManagementPalette.glassGradient(context),
            border: Border.all(
              color: SectionManagementPalette.glassBorder(context),
            ),
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}

class SectionMetricTile extends StatelessWidget {
  const SectionMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.footer,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: color.withValues(alpha: 0.06),
      borderColor: color.withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(footer, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class SectionCapacityBar extends StatelessWidget {
  const SectionCapacityBar({
    super.key,
    required this.value,
    required this.label,
    this.compact = false,
  });

  final double value;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = switch (value) {
      >= 1 => AppColors.danger,
      >= 0.85 => AppColors.warning,
      _ => AppColors.secondary,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
        SizedBox(height: compact ? AppSpacing.xxs : AppSpacing.xs),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: AppMotion.slow,
          curve: AppMotion.entrance,
          builder: (context, animatedValue, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: compact ? 6 : 8,
                value: animatedValue,
                color: color,
                backgroundColor: SectionManagementPalette.progressTrack(
                  context,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class SectionSegmentChip extends StatelessWidget {
  const SectionSegmentChip({
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
    return AnimatedContainer(
      duration: AppMotion.medium,
      curve: AppMotion.emphasized,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : Theme.of(context).cardColor.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.22)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.primary : null,
            ),
          ),
        ),
      ),
    );
  }
}

class SectionPanelHeader extends StatelessWidget {
  const SectionPanelHeader({
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

class SectionPortfolioCard extends StatelessWidget {
  const SectionPortfolioCard({
    super.key,
    required this.record,
    required this.selected,
    required this.onTap,
  });

  final SectionManagementRecord record;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bandColor = capacityBandColor(record.capacityBand);
    return AppCard(
      interactive: true,
      onTap: onTap,
      backgroundColor: selected
          ? bandColor.withValues(alpha: 0.09)
          : Theme.of(context).cardColor.withValues(alpha: 0.90),
      borderColor: selected
          ? bandColor.withValues(alpha: 0.24)
          : Theme.of(context).dividerColor,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight <= 140;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: StatusBadge(record.status)),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                ],
              ),
              SizedBox(height: compact ? AppSpacing.xxs : AppSpacing.xs),
              Text(
                record.code,
                style: compact
                    ? Theme.of(context).textTheme.labelMedium
                    : Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                record.name,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${record.department}  ${record.yearLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: compact ? AppSpacing.xxs : AppSpacing.xs),
              SectionCapacityBar(
                value: record.capacityUsage,
                label: '${record.studentsCount}/${record.capacity} seats used',
                compact: compact,
              ),
            ],
          );
        },
      ),
    );
  }
}

class SectionAvatar extends StatelessWidget {
  const SectionAvatar({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.radius = 22,
  });

  final String label;
  final Color backgroundColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor.withValues(alpha: 0.14),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: backgroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SectionAlertBanner extends StatelessWidget {
  const SectionAlertBanner({super.key, required this.alert});

  final SectionAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = alertToneColor(alert.severity);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color capacityBandColor(SectionCapacityBand band) => switch (band) {
  SectionCapacityBand.available => AppColors.secondary,
  SectionCapacityBand.almostFull => AppColors.warning,
  SectionCapacityBand.full => AppColors.danger,
};

Color alertToneColor(String severity) => switch (severity.toLowerCase()) {
  'critical' => AppColors.danger,
  'warning' => AppColors.warning,
  _ => AppColors.info,
};

Color scheduleTypeColor(String type) => switch (type.toLowerCase()) {
  'lecture' => AppColors.primary,
  'section' => AppColors.secondary,
  'exam' => AppColors.danger,
  'quiz' => AppColors.warning,
  _ => AppColors.info,
};

String formatCompactNumber(num value) => NumberFormat.compact().format(value);

String formatPercentValue(double value) => '${(value * 100).round()}%';
