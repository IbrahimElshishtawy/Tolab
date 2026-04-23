import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../../../../../app_admin/shared/widgets/status_badge.dart';
import '../models/student_workspace_models.dart';

class StudentRowCard extends StatelessWidget {
  const StudentRowCard({
    super.key,
    required this.student,
    required this.selected,
    required this.onToggleSelected,
    required this.onOpenDetails,
  });

  final StudentWorkspaceItem student;
  final bool selected;
  final VoidCallback onToggleSelected;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final accent = switch (student.riskLabel.toLowerCase()) {
      'high risk' => const Color(0xFFDC2626),
      'watch' => const Color(0xFFF59E0B),
      'healthy' => const Color(0xFF14B8A6),
      _ => const Color(0xFF2563EB),
    };

    return AppCard(
      interactive: true,
      onTap: onOpenDetails,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: selected,
            onChanged: (_) => onToggleSelected(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    StatusBadge(student.riskLabel),
                    if (student.isFlagged) StatusBadge('Flagged'),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${student.code} • ${student.subjectCode} • ${student.sectionLabel}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _Metric(label: 'Attendance', value: '${student.attendanceRate}%'),
                    _Metric(label: 'Average score', value: '${student.averageScore.toStringAsFixed(1)}%'),
                    _Metric(label: 'Engagement', value: '${student.engagementScore}'),
                    _Metric(label: 'Last activity', value: student.lastActiveLabel),
                  ],
                ),
                if (student.academicNotes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    student.academicNotes.last,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: accent),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton.tonal(
            onPressed: onOpenDetails,
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
