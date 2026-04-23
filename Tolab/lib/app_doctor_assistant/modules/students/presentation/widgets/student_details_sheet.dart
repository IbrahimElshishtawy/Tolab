import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/shared/widgets/status_badge.dart';
import '../models/student_workspace_models.dart';

class StudentDetailsSheet extends StatelessWidget {
  const StudentDetailsSheet({
    super.key,
    required this.data,
    required this.onSendMessage,
    required this.onAddNote,
    required this.onFlagStudent,
    required this.onViewPerformance,
    required this.onViewAttendance,
  });

  final StudentDetailsData data;
  final VoidCallback onSendMessage;
  final VoidCallback onAddNote;
  final VoidCallback onFlagStudent;
  final VoidCallback onViewPerformance;
  final VoidCallback onViewAttendance;

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
                StatusBadge(data.student.riskLabel),
                StatusBadge(data.student.subjectCode),
                if (data.student.isFlagged) StatusBadge('Flagged'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(data.student.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${data.student.code} • ${data.student.sectionLabel}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                _Stat(label: 'Attendance', value: '${data.student.attendanceRate}%'),
                _Stat(label: 'Average', value: '${data.student.averageScore.toStringAsFixed(1)}%'),
                _Stat(label: 'Engagement', value: '${data.student.engagementScore}'),
                _Stat(label: 'Last activity', value: data.lastActivity),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Grades', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            ...data.gradeRows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(child: Text(row.label)),
                    Text(row.scoreLabel),
                    const SizedBox(width: AppSpacing.sm),
                    StatusBadge(row.statusLabel),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Academic signals', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(data.quizCompletionLabel, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(data.sheetCompletionLabel, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(data.attendanceInsight, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(data.performanceInsight, style: Theme.of(context).textTheme.bodySmall),
            if (data.student.academicNotes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Academic notes', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              ...data.student.academicNotes.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text('• $note', style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed: onSendMessage,
                  icon: const Icon(Icons.mail_outline_rounded),
                  label: const Text('Send message'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onAddNote,
                  icon: const Icon(Icons.note_add_rounded),
                  label: const Text('Add note'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onFlagStudent,
                  icon: const Icon(Icons.outlined_flag_rounded),
                  label: const Text('Flag student'),
                ),
                OutlinedButton.icon(
                  onPressed: onViewPerformance,
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text('View performance'),
                ),
                OutlinedButton.icon(
                  onPressed: onViewAttendance,
                  icon: const Icon(Icons.how_to_reg_rounded),
                  label: const Text('View attendance'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
