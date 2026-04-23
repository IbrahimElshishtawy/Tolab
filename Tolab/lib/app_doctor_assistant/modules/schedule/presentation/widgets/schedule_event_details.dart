import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/shared/widgets/status_badge.dart';
import '../models/schedule_workspace_models.dart';

class ScheduleEventDetailsSheet extends StatelessWidget {
  const ScheduleEventDetailsSheet({
    super.key,
    required this.item,
    required this.conflictReasons,
    required this.onEdit,
    required this.onCancel,
    required this.onReschedule,
    required this.onNotifyStudents,
  });

  final FacultyScheduleItem item;
  final List<String> conflictReasons;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;
  final VoidCallback onNotifyStudents;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                StatusBadge(item.filter.label),
                StatusBadge(item.statusLabel),
                if (item.hasConflict) StatusBadge('Conflict'),
                if (item.isMissingContext) StatusBadge('Needs room/link'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(item.event.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${item.event.subject} • ${item.event.section}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            _DetailRow(label: 'When', value: '${scheduleDateLabel(item.event.startAt)} - ${TimeOfDay.fromDateTime(item.event.endAt).format(context)}'),
            _DetailRow(label: 'Location', value: item.event.location),
            _DetailRow(label: 'Instructor', value: item.event.instructor),
            _DetailRow(label: 'Follow-up', value: item.followUpLabel),
            if (conflictReasons.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Conflict detection', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ...conflictReasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text('• $reason', style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_calendar_rounded),
                  label: const Text('Edit'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onReschedule,
                  icon: const Icon(Icons.update_rounded),
                  label: const Text('Reschedule'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onNotifyStudents,
                  icon: const Icon(Icons.notifications_active_rounded),
                  label: const Text('Notify students'),
                ),
                OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel event'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 94,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
