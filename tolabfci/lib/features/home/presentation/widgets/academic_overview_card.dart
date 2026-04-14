import 'package:flutter/material.dart';

import '../../../../core/models/student_profile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';

class AcademicOverviewCard extends StatelessWidget {
  const AcademicOverviewCard({
    super.key,
    required this.profile,
    required this.courseCount,
  });

  final StudentProfile profile;
  final int courseCount;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Faculty', profile.faculty),
      ('Department', profile.department),
      ('Level', profile.level),
      ('Advisor', profile.academicAdvisor),
      ('Seat number', profile.seatNumber),
      ('GPA', profile.gpa.toStringAsFixed(2)),
      ('Courses', '$courseCount active'),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Academic overview',
            subtitle: 'Your current academic snapshot in one place.',
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 420 ? 2 : 1;
              final tileWidth = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - AppSpacing.md) / 2;

              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: tileWidth,
                        child: _OverviewTile(label: item.$1, value: item.$2),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
