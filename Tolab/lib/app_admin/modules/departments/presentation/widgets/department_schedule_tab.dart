import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/department_models.dart';
import 'department_primitives.dart';

class DepartmentScheduleTab extends StatelessWidget {
  const DepartmentScheduleTab({
    super.key,
    required this.offerings,
    required this.schedulePreview,
  });

  final List<DepartmentCourseOfferingRecord> offerings;
  final List<DepartmentScheduleItem> schedulePreview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DepartmentPanelHeader(
                title: 'Course offerings',
                subtitle: 'Live delivery capacity and enrollment pressure.',
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var index = 0; index < offerings.length; index++) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${offerings[index].subjectCode} • ${offerings[index].sectionLabel}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${offerings[index].instructor} • ${offerings[index].scheduleLabel}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        DepartmentStatusPill(label: offerings[index].status),
                        const SizedBox(height: 6),
                        Text(
                          '${offerings[index].enrolled}/${offerings[index].capacity}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                if (index != offerings.length - 1) ...[
                  const SizedBox(height: AppSpacing.md),
                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DepartmentPanelHeader(
                title: 'Schedule preview',
                subtitle: 'Snapshot of the next representative events.',
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var index = 0; index < schedulePreview.length; index++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        schedulePreview[index].dayLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedulePreview[index].title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${schedulePreview[index].slotLabel} • ${schedulePreview[index].location}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${schedulePreview[index].type} • ${schedulePreview[index].staffName}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (index != schedulePreview.length - 1) ...[
                  const SizedBox(height: AppSpacing.md),
                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
