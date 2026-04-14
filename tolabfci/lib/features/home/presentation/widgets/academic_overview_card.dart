import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../providers/home_providers.dart';

class AcademicOverviewCard extends StatelessWidget {
  const AcademicOverviewCard({super.key, required this.snapshot});

  final StudentAcademicSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('GPA', snapshot.gpa.toStringAsFixed(2)),
      ('المواد', '${snapshot.courseCount}'),
      ('المهام المكتملة', '${snapshot.completedTasks}'),
      ('المعلقة', '${snapshot.pendingTasks}'),
      ('المحاضرات المشاهدة', '${snapshot.viewedLectures}'),
      ('التفاعل', snapshot.engagementSummary),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'نظرة أكاديمية سريعة',
            subtitle: snapshot.academicStatus,
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - AppSpacing.md) / 2;
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: width,
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
    final palette = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
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
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
