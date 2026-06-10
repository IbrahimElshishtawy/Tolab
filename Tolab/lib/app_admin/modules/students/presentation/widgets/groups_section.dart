import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/student_management_models.dart';
import '../../widgets/student_module_primitives.dart';

class GroupsSection extends StatelessWidget {
  const GroupsSection({
    super.key,
    required this.snapshot,
    required this.onNotifyGroup,
  });

  final StudentModuleSnapshot snapshot;
  final ValueChanged<StudentGroupRecord> onNotifyGroup;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final group in snapshot.groups)
          SizedBox(
            width: MediaQuery.sizeOf(context).width < 960
                ? double.infinity
                : 320,
            child: StudentSectionCard(
              title: group.name,
              subtitle:
                  '${group.department} • Year ${group.year} • ${group.className}',
              trailing: IconButton(
                onPressed: () => onNotifyGroup(group),
                icon: const Icon(Icons.notifications_active_rounded),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Course: ${group.courseTitle}'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Members: ${group.memberIds.length} • Leader: ${snapshot.findStudent(group.leaderId)?.fullName ?? 'Unassigned'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final memberId in group.memberIds)
                        StudentStatusPill(
                          label:
                              snapshot.findStudent(memberId)?.fullName ??
                              memberId,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
