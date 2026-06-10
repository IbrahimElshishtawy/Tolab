import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/schedule_models.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/section_management_models.dart';
import '../design/section_management_tokens.dart';
import 'section_management_primitives.dart';

class SectionDesktopSidebar extends StatelessWidget {
  const SectionDesktopSidebar({
    super.key,
    required this.selectedRecord,
    required this.records,
    required this.activeTab,
    required this.visibleAlerts,
    required this.previewEvents,
  });

  final SectionManagementRecord selectedRecord;
  final List<SectionManagementRecord> records;
  final SectionDetailTab activeTab;
  final List<SectionAlert> visibleAlerts;
  final List<ScheduleEventModel> previewEvents;

  @override
  Widget build(BuildContext context) {
    final busiestSections = [...records]
      ..sort((a, b) => b.capacityUsage.compareTo(a.capacityUsage));

    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionPanelHeader(
                title: context.l10n.byValue('Capacity watch'),
                subtitle:
                    context.l10n.byValue('Real-time operational signals across this section and nearby cohorts.'),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCapacityBar(
                value: selectedRecord.capacityUsage,
                label:
                    '${selectedRecord.studentsCount}/${selectedRecord.capacity} ${context.l10n.byValue('occupied')}',
              ),
              const SizedBox(height: AppSpacing.md),
              for (final alert in visibleAlerts.take(3)) ...[
                SectionAlertBanner(alert: alert),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
              for (final section in busiestSections.take(3)) ...[
                _SidebarLoadTile(record: section),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _DesktopMobilePreview(
          record: selectedRecord,
          activeTab: activeTab,
          events: previewEvents,
        ),
      ],
    );
  }
}

class _SidebarLoadTile extends StatelessWidget {
  const _SidebarLoadTile({required this.record});

  final SectionManagementRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.code,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              StatusBadge(record.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCapacityBar(
            value: record.capacityUsage,
            label: '${record.studentsCount}/${record.capacity} ${context.l10n.byValue('seats')}',
          ),
        ],
      ),
    );
  }
}

class _DesktopMobilePreview extends StatelessWidget {
  const _DesktopMobilePreview({
    required this.record,
    required this.activeTab,
    required this.events,
  });

  final SectionManagementRecord record;
  final SectionDetailTab activeTab;
  final List<ScheduleEventModel> events;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionPanelHeader(
            title: context.l10n.byValue('Mobile preview'),
            subtitle:
                context.l10n.byValue('A compact iOS-style adaptation for on-the-go section management.'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              width: 290,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SectionManagementPalette.mobileFrame(context),
                borderRadius: BorderRadius.circular(38),
                boxShadow: [
                  BoxShadow(
                    color: SectionManagementPalette.softShadow(
                      context,
                    ).withValues(alpha: 0.22),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  color: SectionManagementPalette.mobileCanvas(context),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: 5,
                          width: 68,
                          decoration: BoxDecoration(
                            color: SectionManagementPalette.mobileHandle(
                              context,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        record.code,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        record.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      StatusBadge(record.status),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        backgroundColor: SectionManagementPalette.surface(
                          context,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.byValue('Capacity'),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            SectionCapacityBar(
                              value: record.capacityUsage,
                              label:
                                  '${record.studentsCount}/${record.capacity} ${context.l10n.byValue('seats')}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _mobilePreviewTitle(context, activeTab),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (activeTab == SectionDetailTab.schedule)
                        for (final event in events)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _MobileEventCard(event: event),
                          )
                      else if (activeTab == SectionDetailTab.students)
                        for (final student in record.students.take(3))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _CompactStudentCell(student: student),
                          )
                      else if (activeTab == SectionDetailTab.subjects)
                        for (final subject in record.subjects.take(3))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _CompactSubjectCell(subject: subject),
                          )
                      else if (activeTab == SectionDetailTab.staff)
                        for (final staff in record.staff.take(3))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _CompactStaffCell(member: staff),
                          )
                      else
                        Column(
                          children: [
                            _CompactOverviewStat(
                              label: context.l10n.byValue('Students'),
                              value: record.studentsCount.toString(),
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _CompactOverviewStat(
                              label: context.l10n.byValue('Subjects'),
                              value: record.subjectsCount.toString(),
                              color: AppColors.secondary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _CompactOverviewStat(
                              label: context.l10n.byValue('Staff'),
                              value: record.staffCount.toString(),
                              color: AppColors.info,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _mobilePreviewTitle(BuildContext context, SectionDetailTab tab) => switch (tab) {
    SectionDetailTab.overview => context.l10n.byValue('Quick summary'),
    SectionDetailTab.students => context.l10n.byValue('Roster cards'),
    SectionDetailTab.schedule => context.l10n.byValue('Agenda'),
    SectionDetailTab.subjects => context.l10n.byValue('Subject list'),
    SectionDetailTab.staff => context.l10n.byValue('Staff cards'),
  };
}

class _MobileEventCard extends StatelessWidget {
  const _MobileEventCard({required this.event});

  final ScheduleEventModel event;

  @override
  Widget build(BuildContext context) {
    final color = scheduleTypeColor(event.type);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: color.withValues(alpha: 0.06),
      borderColor: color.withValues(alpha: 0.16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusBadge(event.type.toUpperCase()),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(event.course, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          _MetricLine(
            label: context.l10n.byValue('Time'),
            value:
                '${DateFormat('hh:mm a').format(event.start)} - ${DateFormat('hh:mm a').format(event.end)}',
          ),
          const SizedBox(height: AppSpacing.xs),
          _MetricLine(label: context.l10n.byValue('Instructor'), value: context.l10n.byValue(event.instructor)),
          const SizedBox(height: AppSpacing.xs),
          _MetricLine(label: context.l10n.byValue('Location'), value: context.l10n.byValue(event.location)),
        ],
      ),
    );
  }
}

class _CompactStudentCell extends StatelessWidget {
  const _CompactStudentCell({required this.student});

  final SectionStudentRecord student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SectionManagementPalette.surface(context),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          SectionAvatar(
            label: student.initials,
            backgroundColor: AppColors.primary,
            radius: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  context.l10n.byValue(student.name),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  context.l10n.byValue(student.yearLabel),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          StatusBadge(student.status),
        ],
      ),
    );
  }
}

class _CompactSubjectCell extends StatelessWidget {
  const _CompactSubjectCell({required this.subject});

  final SectionSubjectRecord subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SectionManagementPalette.surface(context),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.code,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  context.l10n.byValue(subject.title),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${(subject.completionRate * 100).round()}%',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _CompactStaffCell extends StatelessWidget {
  const _CompactStaffCell({required this.member});

  final SectionStaffRecord member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SectionManagementPalette.surface(context),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          SectionAvatar(
            label: member.initials,
            backgroundColor: member.role == 'Doctor'
                ? AppColors.primary
                : AppColors.info,
            radius: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.byValue(member.name),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(context.l10n.byValue(member.role), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(
            member.status == 'Active'
                ? Icons.check_circle_rounded
                : Icons.pause_circle_rounded,
            size: 18,
            color: member.status == 'Active'
                ? AppColors.secondary
                : AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _CompactOverviewStat extends StatelessWidget {
  const _CompactOverviewStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SectionManagementPalette.surface(context),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.insights_rounded, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
