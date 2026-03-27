import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/department_models.dart';
import 'department_primitives.dart';

class DepartmentSubjectsTab extends StatelessWidget {
  const DepartmentSubjectsTab({super.key, required this.subjects});

  final List<DepartmentSubjectRecord> subjects;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: subjects.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      subject.code,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  DepartmentStatusPill(label: subject.status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _InfoPill(label: subject.yearLabel),
                  _InfoPill(label: subject.semesterLabel),
                  _InfoPill(
                    label:
                        '${formatCompactNumber(subject.enrolledStudents)} students',
                  ),
                  _InfoPill(label: '${subject.weeklyHours}h weekly'),
                ],
              ),
              if (subject.overloaded) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'This subject is currently above the preferred delivery load.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

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
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
