import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/staff_admin_models.dart';
import '../design/staff_management_tokens.dart';
import 'staff_status_badge.dart';

class StaffAvatarBadge extends StatelessWidget {
  const StaffAvatarBadge({
    super.key,
    required this.fullName,
    required this.isDoctor,
    this.size = 46,
    this.radius = 16,
  });

  final String fullName;
  final bool isDoctor;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = fullName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();
    final colors = isDoctor
        ? const [StaffManagementPalette.doctor, StaffManagementPalette.internal]
        : const [
            StaffManagementPalette.assistant,
            StaffManagementPalette.engagement,
          ];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        initials,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}

class StaffMetricMeter extends StatelessWidget {
  const StaffMetricMeter({
    super.key,
    required this.value,
    required this.primary,
    required this.secondary,
    required this.color,
    this.compact = false,
  });

  final double value;
  final String primary;
  final String secondary;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: StaffManagementPalette.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(primary, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(secondary, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.pillRadius),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              minHeight: compact ? 7 : 8,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class StaffInfoTile extends StatelessWidget {
  const StaffInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.width,
  });

  final String label;
  final String value;
  final IconData? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: StaffManagementDecorations.outline(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: StaffManagementPalette.subtleText(context),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class StaffInfoPill extends StatelessWidget {
  const StaffInfoPill({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(color: StaffManagementPalette.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: StaffManagementPalette.subtleText(context),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class StaffActionIconButton extends StatelessWidget {
  const StaffActionIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(onPressed: onPressed, icon: Icon(icon, size: 18)),
    );
  }
}

class StaffTimelineTile extends StatelessWidget {
  const StaffTimelineTile({super.key, required this.event});

  final StaffTimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final color = switch (event.emphasis) {
      'critical' => StaffManagementPalette.risk,
      'attention' => StaffManagementPalette.delegated,
      'strong' => StaffManagementPalette.attendance,
      _ => StaffManagementPalette.doctor,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              border: Border.all(color: StaffManagementPalette.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    StaffStatusBadge(event.timeLabel),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StaffSubjectActivityCard extends StatelessWidget {
  const StaffSubjectActivityCard({super.key, required this.subject});

  final StaffSubjectAssignment subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: StaffManagementPalette.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subject.code} • ${subject.title}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.section,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StaffStatusBadge(subject.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StaffStatusBadge('${subject.lectures} lectures'),
              StaffStatusBadge('${subject.tasks} tasks'),
              StaffStatusBadge('${subject.posts} posts'),
              StaffStatusBadge('${subject.uploads} uploads'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          StaffMetricMeter(
            value: subject.engagementRate / 100,
            primary: '${subject.engagementRate.round()}% engagement',
            secondary: 'Academic activity level for this assignment',
            color: StaffManagementPalette.engagement,
            compact: true,
          ),
        ],
      ),
    );
  }
}
