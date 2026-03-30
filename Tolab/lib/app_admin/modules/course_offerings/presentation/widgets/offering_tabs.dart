import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/course_offering_model.dart';
import 'offering_card.dart';

class OfferingTabs extends StatelessWidget {
  const OfferingTabs({
    super.key,
    required this.offering,
    required this.activeTab,
    required this.onTabChanged,
    required this.onAddStudent,
    required this.onRemoveStudent,
    required this.onQuickAction,
  });

  final CourseOfferingModel offering;
  final CourseOfferingDetailsTab activeTab;
  final ValueChanged<CourseOfferingDetailsTab> onTabChanged;
  final VoidCallback onAddStudent;
  final ValueChanged<CourseOfferingStudent> onRemoveStudent;
  final ValueChanged<CourseOfferingQuickAction> onQuickAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoSlidingSegmentedControl<CourseOfferingDetailsTab>(
            groupValue: activeTab,
            children: {
              for (final tab in CourseOfferingDetailsTab.values)
                tab: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(tab.label),
                ),
            },
            onValueChanged: (value) {
              if (value != null) onTabChanged(value);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (activeTab) {
              CourseOfferingDetailsTab.overview => _OverviewTab(
                key: const ValueKey('overview'),
                offering: offering,
              ),
              CourseOfferingDetailsTab.students => _StudentsTab(
                key: const ValueKey('students'),
                students: offering.students,
                onAddStudent: onAddStudent,
                onRemoveStudent: onRemoveStudent,
              ),
              CourseOfferingDetailsTab.schedule => _ScheduleTab(
                key: const ValueKey('schedule'),
                offering: offering,
              ),
              CourseOfferingDetailsTab.content => _ContentTab(
                key: const ValueKey('content'),
                offering: offering,
                onQuickAction: onQuickAction,
              ),
              CourseOfferingDetailsTab.staff => _StaffTab(
                key: const ValueKey('staff'),
                offering: offering,
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({super.key, required this.offering});

  final CourseOfferingModel offering;

  @override
  Widget build(BuildContext context) {
    final stats = <({String label, String value, IconData icon, Color color})>[
      (
        label: 'Enrolled',
        value: '${offering.enrolledCount}',
        icon: Icons.groups_rounded,
        color: AppColors.primary,
      ),
      (
        label: 'Capacity',
        value: '${offering.capacity}',
        icon: Icons.event_seat_rounded,
        color: AppColors.secondary,
      ),
      (
        label: 'Seats left',
        value: '${offering.seatsRemaining}',
        icon: Icons.chair_alt_outlined,
        color: AppColors.warning,
      ),
      (
        label: 'Created',
        value: DateFormat('d MMM yyyy').format(offering.createdAt),
        icon: Icons.schedule_rounded,
        color: AppColors.info,
      ),
    ];

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final stat in stats)
              SizedBox(
                width: 220,
                child: _MetricTile(
                  label: stat.label,
                  value: stat.value,
                  icon: stat.icon,
                  color: stat.color,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Panel(
                title: 'Basic info',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LineItem(label: 'Subject', value: offering.subjectName),
                    _LineItem(label: 'Code', value: offering.code),
                    _LineItem(
                      label: 'Department',
                      value: offering.departmentName,
                    ),
                    _LineItem(label: 'Section', value: offering.sectionName),
                    _LineItem(
                      label: 'Academic cycle',
                      value: '${offering.semester} - ${offering.academicYear}',
                    ),
                    _LineItem(
                      label: 'Duration',
                      value:
                          '${DateFormat('d MMM').format(offering.startDate)} - ${DateFormat('d MMM yyyy').format(offering.endDate)}',
                    ),
                  ],
                ),
              ),
            ),
            if (AppBreakpoints.isDesktop(context))
              const SizedBox(width: AppSpacing.md),
            if (AppBreakpoints.isDesktop(context))
              Expanded(
                child: _Panel(
                  title: 'Capacity health',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${offering.enrolledCount} students enrolled',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          OfferingStatusBadge(status: offering.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.pillRadius,
                        ),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: offering.fillRate.clamp(0, 1),
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.10,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            offering.fillRate >= 0.95
                                ? AppColors.danger
                                : offering.fillRate >= 0.75
                                ? AppColors.warning
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${(offering.fillRate * 100).round()}% filled - ${offering.seatsRemaining} seats remaining',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (!AppBreakpoints.isDesktop(context)) ...[
          const SizedBox(height: AppSpacing.md),
          _Panel(
            title: 'Capacity health',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OfferingStatusBadge(status: offering.status),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: offering.fillRate.clamp(0, 1),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      offering.fillRate >= 0.95
                          ? AppColors.danger
                          : offering.fillRate >= 0.75
                          ? AppColors.warning
                          : AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${(offering.fillRate * 100).round()}% filled - ${offering.seatsRemaining} seats remaining',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StudentsTab extends StatelessWidget {
  const _StudentsTab({
    super.key,
    required this.students,
    required this.onAddStudent,
    required this.onRemoveStudent,
  });

  final List<CourseOfferingStudent> students;
  final VoidCallback onAddStudent;
  final ValueChanged<CourseOfferingStudent> onRemoveStudent;

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${students.length} enrolled students',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            PremiumButton(
              label: 'Add student',
              icon: Icons.person_add_alt_rounded,
              onPressed: onAddStudent,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isDesktop)
          AppCard(
            padding: EdgeInsets.zero,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.6),
                1: FlexColumnWidth(1.8),
                2: FlexColumnWidth(1.2),
                3: FlexColumnWidth(0.6),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.04),
                  ),
                  children: const [
                    _TableHeader('Student'),
                    _TableHeader('Email'),
                    _TableHeader('Section'),
                    _TableHeader(''),
                  ],
                ),
                for (final student in students)
                  TableRow(
                    children: [
                      _TableCell(student.name),
                      _TableCell(student.email),
                      _TableCell(student.sectionName),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => onRemoveStudent(student),
                            icon: const Icon(
                              Icons.person_remove_alt_1_outlined,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (final student in students) ...[
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primarySoft,
                        child: Text(student.name.characters.first),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name),
                            const SizedBox(height: 4),
                            Text(
                              student.email,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => onRemoveStudent(student),
                        icon: const Icon(Icons.person_remove_alt_1_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
      ],
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({super.key, required this.offering});

  final CourseOfferingModel offering;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          title: 'Schedule integration',
          child: Text(
            'This schedule panel is ready for timetable service integration and currently shows the seeded cohort layout.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final item in offering.schedule) ...[
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                  ),
                  child: Text(item.dayLabel),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.timeLabel} - ${item.location} - ${item.type}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  item.status,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.secondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ContentTab extends StatelessWidget {
  const _ContentTab({
    super.key,
    required this.offering,
    required this.onQuickAction,
  });

  final CourseOfferingModel offering;
  final ValueChanged<CourseOfferingQuickAction> onQuickAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final action in offering.contentActions)
              SizedBox(
                width: 240,
                child: AppCard(
                  interactive: true,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  onTap: () => onQuickAction(action),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: _quickActionColor(
                            action.kind,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            AppConstants.mediumRadius,
                          ),
                        ),
                        child: Icon(
                          _quickActionIcon(action.kind),
                          color: _quickActionColor(action.kind),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        action.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        action.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StaffTab extends StatelessWidget {
  const _StaffTab({super.key, required this.offering});

  final CourseOfferingModel offering;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StaffCard(member: offering.doctor),
        const SizedBox(height: AppSpacing.md),
        for (final assistant in offering.assistants) ...[
          _StaffCard(member: assistant),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.member});

  final CourseOfferingStaffMember member;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: member.role == 'Doctor'
                ? AppColors.primarySoft
                : AppColors.infoSoft,
            child: Text(member.name.characters.first),
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
                const SizedBox(height: 4),
                Text(
                  member.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${member.role} - ${member.department}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Text(label),
    );
  }
}

Color _quickActionColor(CourseOfferingQuickActionKind kind) {
  return switch (kind) {
    CourseOfferingQuickActionKind.lecture => AppColors.primary,
    CourseOfferingQuickActionKind.upload => AppColors.info,
    CourseOfferingQuickActionKind.assignment => AppColors.warning,
    CourseOfferingQuickActionKind.announcement => AppColors.secondary,
  };
}

IconData _quickActionIcon(CourseOfferingQuickActionKind kind) {
  return switch (kind) {
    CourseOfferingQuickActionKind.lecture => Icons.play_lesson_outlined,
    CourseOfferingQuickActionKind.upload => Icons.upload_file_outlined,
    CourseOfferingQuickActionKind.assignment => Icons.assignment_outlined,
    CourseOfferingQuickActionKind.announcement => Icons.campaign_outlined,
  };
}
