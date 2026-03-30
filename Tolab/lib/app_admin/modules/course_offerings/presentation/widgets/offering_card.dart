import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/course_offering_model.dart';

class OfferingCard extends StatelessWidget {
  const OfferingCard({
    super.key,
    required this.offering,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final CourseOfferingModel offering;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final fillColor = _capacityColor(offering);
    final rangeLabel =
        '${DateFormat('d MMM').format(offering.startDate)} - ${DateFormat('d MMM yyyy').format(offering.endDate)}';

    return AppCard(
      interactive: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offering.code,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      offering.subjectName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              OfferingStatusBadge(status: offering.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: offering.doctor.name,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.grid_view_rounded,
            label: '${offering.sectionName} - ${offering.semester}',
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(icon: Icons.event_outlined, label: rangeLabel),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Capacity',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.pillRadius,
                      ),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: offering.fillRate.clamp(0, 1),
                        backgroundColor: fillColor.withValues(alpha: 0.16),
                        valueColor: AlwaysStoppedAnimation<Color>(fillColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${offering.enrolledCount}/${offering.capacity}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              TextButton.icon(
                onPressed: onView,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View'),
              ),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OfferingStatusBadge extends StatelessWidget {
  const OfferingStatusBadge({super.key, required this.status});

  final CourseOfferingStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      CourseOfferingStatus.active => (
        AppColors.secondary,
        AppColors.secondarySoft,
      ),
      CourseOfferingStatus.draft => (AppColors.slate, AppColors.slateSoft),
      CourseOfferingStatus.completed => (AppColors.info, AppColors.infoSoft),
      CourseOfferingStatus.cancelled => (
        AppColors.danger,
        AppColors.dangerSoft,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

Color _capacityColor(CourseOfferingModel offering) {
  if (offering.fillRate >= 0.95) return AppColors.danger;
  if (offering.fillRate >= 0.75) return AppColors.warning;
  return AppColors.secondary;
}
