import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../../../../../app_admin/shared/widgets/premium_button.dart';
import '../../../../../app_admin/shared/widgets/status_badge.dart';
import '../../../../core/models/content_models.dart';

class LectureCard extends StatelessWidget {
  const LectureCard({
    super.key,
    required this.lecture,
    this.onEdit,
    this.onPublish,
    this.onCopyLink,
  });

  final LectureModel lecture;
  final VoidCallback? onEdit;
  final VoidCallback? onPublish;
  final VoidCallback? onCopyLink;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        Text(
                          lecture.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        StatusBadge(lecture.statusLabel),
                        if ((lecture.subjectName ?? '').isNotEmpty)
                          StatusBadge(lecture.subjectName!),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      lecture.description ?? '${lecture.deliveryMode} lecture delivery',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.slideshow_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _Meta(icon: Icons.calendar_today_rounded, label: lecture.startsAt ?? 'Not scheduled'),
              _Meta(
                icon: lecture.deliveryMode.toLowerCase().contains('online')
                    ? Icons.language_rounded
                    : Icons.place_rounded,
                label: lecture.locationLabel ?? lecture.meetingUrl ?? 'TBA',
              ),
              _Meta(icon: Icons.person_rounded, label: lecture.publisherName ?? lecture.instructorName),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              PremiumButton(
                label: 'View',
                icon: Icons.visibility_outlined,
                isSecondary: true,
                onPressed: onEdit,
              ),
              PremiumButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                isSecondary: true,
                onPressed: onEdit,
              ),
              if (lecture.statusLabel.toLowerCase() == 'draft' ||
                  lecture.statusLabel.toLowerCase() == 'scheduled')
                PremiumButton(
                  label: 'Publish',
                  icon: Icons.publish_rounded,
                  onPressed: onPublish,
                ),
              PremiumButton(
                label: 'Copy link',
                icon: Icons.link_rounded,
                isSecondary: true,
                onPressed: onCopyLink,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
