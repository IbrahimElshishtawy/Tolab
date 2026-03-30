import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../charts/department_analytics_charts.dart';
import '../../models/department_models.dart';
import 'department_primitives.dart';

class DepartmentStaffTab extends StatelessWidget {
  const DepartmentStaffTab({super.key, required this.staff});

  final List<DepartmentStaffRecord> staff;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: staff.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final member = staff[index];
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  DepartmentAvatar(
                    imageUrl: member.avatarUrl,
                    fallback: member.name,
                    radius: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${member.role} • ${member.activeSubjects} active subjects',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  DepartmentStatusPill(label: member.status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Utilization ${formatPercent(member.utilization)}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  Text(
                    member.role,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              DepartmentMiniProgressBar(
                value: member.utilization,
                color: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}
