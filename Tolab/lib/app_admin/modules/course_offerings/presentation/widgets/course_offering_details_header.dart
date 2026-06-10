import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/course_offering_model.dart';

class CourseOfferingDetailsHeader extends StatelessWidget {
  const CourseOfferingDetailsHeader({
    super.key,
    required this.offering,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  final CourseOfferingModel? offering;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offering?.subjectName ?? 'Offering details',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              offering == null
                  ? 'Loading course offering details.'
                  : '${offering!.code} - ${offering!.sectionName} - ${offering!.semester} ${offering!.academicYear}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
        final actions = offering == null
            ? const <Widget>[]
            : [
                PremiumButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  isSecondary: true,
                  onPressed: onEdit,
                ),
                PremiumButton(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  isSecondary: true,
                  onPressed: onDelete,
                ),
              ];

        return compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  titleBlock,
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: actions,
                    ),
                  ],
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: titleBlock),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: actions,
                    ),
                  ],
                ],
              );
      },
    );
  }
}
