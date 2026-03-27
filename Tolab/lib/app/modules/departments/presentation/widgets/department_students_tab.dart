import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/department_models.dart';
import 'department_primitives.dart';

class DepartmentStudentsTab extends StatelessWidget {
  const DepartmentStudentsTab({super.key, required this.students});

  final List<DepartmentStudentRecord> students;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: students.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final student = students[index];
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(student.name.characters.first.toUpperCase()),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${student.id} • ${student.yearLabel} • ${student.sectionLabel}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  DepartmentStatusPill(label: student.status),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'GPA ${student.gpa.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
