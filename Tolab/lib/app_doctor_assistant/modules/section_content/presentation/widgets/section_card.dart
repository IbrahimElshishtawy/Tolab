import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../../../core/design/app_spacing.dart';
import '../models/sections_workspace_models.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.section,
    required this.onView,
    required this.onEdit,
    required this.onPublish,
    required this.onCopyLink,
    required this.onNotifyStudents,
  });

  final SectionWorkspaceItem section;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onPublish;
  final VoidCallback onCopyLink;
  final VoidCallback onNotifyStudents;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: section.accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  section.subjectCode,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: section.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DashboardToneBadge(
                label: section.statusLabel,
                tone: section.statusTone,
              ),
              DashboardToneBadge(
                label: section.deliveryType,
                tone: section.deliveryType == 'Online' ? 'primary' : 'success',
              ),
              if (section.isToday)
                const DashboardToneBadge(label: 'Today', tone: 'warning'),
              if (section.isLive)
                const DashboardToneBadge(label: 'Live now', tone: 'danger'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            section.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            section.subjectLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _MetaChip(
                icon: Icons.calendar_today_rounded,
                label: section.dateLabel,
              ),
              _MetaChip(icon: Icons.schedule_rounded, label: section.timeLabel),
              _MetaChip(
                icon: Icons.person_rounded,
                label: section.assistantName,
              ),
              _MetaChip(
                icon: section.deliveryType == 'Online'
                    ? Icons.videocam_rounded
                    : Icons.meeting_room_rounded,
                label: section.locationLabel,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            section.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _MiniInfo(
                label: 'Expected',
                value: '${section.expectedStudents} students',
              ),
              _MiniInfo(
                label: 'Action',
                value: section.needsLink ? 'Link required' : 'Ready to run',
              ),
              _MiniInfo(
                label: 'Attachment',
                value: section.attachmentName ?? 'No file attached',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.tonalIcon(
                onPressed: onView,
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: const Text('View'),
              ),
              FilledButton.tonalIcon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit'),
              ),
              FilledButton.tonalIcon(
                onPressed: onPublish,
                icon: const Icon(Icons.publish_rounded, size: 18),
                label: const Text('Publish'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCopyLink,
                icon: const Icon(Icons.link_rounded, size: 18),
                label: const Text('Copy Link'),
              ),
              FilledButton.tonalIcon(
                onPressed: onNotifyStudents,
                icon: const Icon(Icons.notifications_active_rounded, size: 18),
                label: const Text('Notify Students'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tokens.primary),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 220),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
