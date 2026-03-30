import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/staff_admin_models.dart';
import '../charts/staff_analytics_charts.dart';
import '../design/staff_management_tokens.dart';
import 'staff_section_card.dart';
import 'staff_segmented_control.dart';
import 'staff_status_badge.dart';

class StaffAnalyticsSection extends StatelessWidget {
  const StaffAnalyticsSection({
    super.key,
    required this.records,
    required this.assistantDepartmentFilter,
    required this.doctorAttendanceMode,
    required this.doctorEngagementMode,
    required this.assistantAttendanceMode,
    required this.assistantEngagementMode,
    required this.onAssistantDepartmentChanged,
    required this.onDoctorAttendanceModeChanged,
    required this.onDoctorEngagementModeChanged,
    required this.onAssistantAttendanceModeChanged,
    required this.onAssistantEngagementModeChanged,
  });

  final List<StaffAdminRecord> records;
  final String assistantDepartmentFilter;
  final String doctorAttendanceMode;
  final String doctorEngagementMode;
  final String assistantAttendanceMode;
  final String assistantEngagementMode;
  final ValueChanged<String> onAssistantDepartmentChanged;
  final ValueChanged<String> onDoctorAttendanceModeChanged;
  final ValueChanged<String> onDoctorEngagementModeChanged;
  final ValueChanged<String> onAssistantAttendanceModeChanged;
  final ValueChanged<String> onAssistantEngagementModeChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = constraints.maxWidth < 760
            ? StaffManagementSpacing.compactAnalyticsMinWidth
            : StaffManagementSpacing.analyticsMinWidth;
        final doctors = records.where((item) => item.isDoctor).toList();
        final assistants = records.where((item) => item.isAssistant).toList();

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: _cardWidth(constraints.maxWidth, minWidth),
              child: _AnimatedAnalyticsCard(
                index: 0,
                child: _DoctorBreakdownCard(doctors: doctors),
              ),
            ),
            SizedBox(
              width: _cardWidth(constraints.maxWidth, minWidth),
              child: _AnimatedAnalyticsCard(
                index: 1,
                child: _AssistantsCard(
                  assistants: assistants,
                  departmentFilter: assistantDepartmentFilter,
                  onDepartmentChanged: onAssistantDepartmentChanged,
                ),
              ),
            ),
            SizedBox(
              width: _cardWidth(constraints.maxWidth, minWidth),
              child: _AnimatedAnalyticsCard(
                index: 2,
                child: _AttendanceCard(
                  title: 'Doctors attendance analytics',
                  subtitle:
                      'Monitor presence reliability, status distribution, and recent trend for doctors.',
                  records: doctors,
                  mode: doctorAttendanceMode,
                  onModeChanged: onDoctorAttendanceModeChanged,
                ),
              ),
            ),
            SizedBox(
              width: _cardWidth(constraints.maxWidth, minWidth),
              child: _AnimatedAnalyticsCard(
                index: 3,
                child: _EngagementCard(
                  title: 'Doctors subject interaction',
                  subtitle:
                      'Track lectures, tasks, posts, and academic activity produced by doctors.',
                  records: doctors,
                  mode: doctorEngagementMode,
                  onModeChanged: onDoctorEngagementModeChanged,
                  accent: StaffManagementPalette.engagement,
                ),
              ),
            ),
            SizedBox(
              width: _cardWidth(constraints.maxWidth, minWidth),
              child: _AnimatedAnalyticsCard(
                index: 4,
                child: _AttendanceCard(
                  title: 'Assistants attendance analytics',
                  subtitle:
                      'Keep assistant attendance visible with health bands and a rolling weekly pulse.',
                  records: assistants,
                  mode: assistantAttendanceMode,
                  onModeChanged: onAssistantAttendanceModeChanged,
                ),
              ),
            ),
            SizedBox(
              width: _cardWidth(constraints.maxWidth, minWidth),
              child: _AnimatedAnalyticsCard(
                index: 5,
                child: _EngagementCard(
                  title: 'Assistants subject interaction',
                  subtitle:
                      'Measure section support, uploads, academic follow-up, and classroom engagement.',
                  records: assistants,
                  mode: assistantEngagementMode,
                  onModeChanged: onAssistantEngagementModeChanged,
                  accent: StaffManagementPalette.assistant,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _cardWidth(double availableWidth, double minWidth) {
    if (availableWidth >= 1500) return (availableWidth - (AppSpacing.md * 2)) / 3;
    if (availableWidth >= 980) return (availableWidth - AppSpacing.md) / 2;
    return availableWidth > minWidth ? availableWidth : minWidth;
  }
}

class _DoctorBreakdownCard extends StatelessWidget {
  const _DoctorBreakdownCard({required this.doctors});

  final List<StaffAdminRecord> doctors;

  @override
  Widget build(BuildContext context) {
    final internal = doctors.where((item) => item.isInternalDoctor).length;
    final delegated = doctors.length - internal;
    final active = doctors.where((item) => item.status == 'Active').length;
    return StaffSectionCard(
      title: 'Doctor accounts created',
      subtitle:
          'Separate internal faculty accounts from delegated teaching doctors with clear totals.',
      accent: StaffManagementPalette.doctor,
      footer: _AnalyticsFooter(
        accent: StaffManagementPalette.doctor,
        text:
            '$active doctor accounts are active and monitored inside the university control center.',
      ),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: StaffDonutChart(
              slices: [
                StaffChartSlice(
                  label: 'Internal faculty',
                  value: internal.toDouble(),
                  color: StaffManagementPalette.internal,
                ),
                StaffChartSlice(
                  label: 'Delegated / external',
                  value: delegated.toDouble(),
                  color: StaffManagementPalette.delegated,
                ),
              ],
              centerTitle: doctors.length.toString(),
              centerSubtitle: 'Total doctors',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: const [
              StaffStatusBadge('Internal faculty doctor'),
              StaffStatusBadge('Delegated / external doctor'),
              StaffStatusBadge(
                'Active',
                icon: Icons.check_circle_outline_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssistantsCard extends StatelessWidget {
  const _AssistantsCard({
    required this.assistants,
    required this.departmentFilter,
    required this.onDepartmentChanged,
  });

  final List<StaffAdminRecord> assistants;
  final String departmentFilter;
  final ValueChanged<String> onDepartmentChanged;

  @override
  Widget build(BuildContext context) {
    final departments = [
      'All departments',
      ...{for (final item in assistants) item.department},
    ];
    final filtered = departmentFilter == 'All departments'
        ? assistants
        : assistants.where((item) => item.department == departmentFilter).toList();

    return StaffSectionCard(
      title: 'Teaching assistants accounts',
      subtitle:
          'Review assistant coverage across departments and keep staffing load balanced.',
      accent: StaffManagementPalette.assistant,
      trailing: _CompactDropdown(
        value: departmentFilter,
        items: departments,
        onChanged: (value) => onDepartmentChanged(value ?? departmentFilter),
      ),
      footer: _AnalyticsFooter(
        accent: StaffManagementPalette.assistant,
        text:
            '${assistants.where((item) => item.status == 'Active').length} assistants are currently active in live academic delivery.',
      ),
      child: SizedBox(
        height: 190,
        child: departmentFilter == 'All departments'
            ? StaffBarChart(
                slices: _barFromDepartments(assistants),
                maxY: assistants.length.toDouble() + 1,
              )
            : StaffDonutChart(
                slices: [
                  StaffChartSlice(
                    label: 'Active',
                    value: filtered
                        .where((item) => item.status == 'Active')
                        .length
                        .toDouble(),
                    color: StaffManagementPalette.attendance,
                  ),
                  StaffChartSlice(
                    label: 'Inactive',
                    value: filtered
                        .where((item) => item.status != 'Active')
                        .length
                        .toDouble(),
                    color: StaffManagementPalette.risk,
                  ),
                ],
                centerTitle: filtered.length.toString(),
                centerSubtitle: 'Assistants',
              ),
      ),
    );
  }

  List<StaffChartSlice> _barFromDepartments(List<StaffAdminRecord> records) {
    final grouped = <String, int>{};
    for (final record in records) {
      grouped.update(record.department, (value) => value + 1, ifAbsent: () => 1);
    }
    final colors = const [
      StaffManagementPalette.assistant,
      StaffManagementPalette.doctor,
      StaffManagementPalette.internal,
    ];
    var index = 0;
    return grouped.entries.map((entry) {
      final slice = StaffChartSlice(
        label: entry.key.split(' ').first,
        value: entry.value.toDouble(),
        color: colors[index % colors.length],
      );
      index++;
      return slice;
    }).toList();
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.title,
    required this.subtitle,
    required this.records,
    required this.mode,
    required this.onModeChanged,
  });

  final String title;
  final String subtitle;
  final List<StaffAdminRecord> records;
  final String mode;
  final ValueChanged<String> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final average = records.isEmpty
        ? 0
        : records.fold<double>(0, (sum, item) => sum + item.attendanceRate) /
              records.length;
    return StaffSectionCard(
      title: title,
      subtitle: subtitle,
      accent: StaffManagementPalette.attendance,
      trailing: StaffSegmentedControl(
        options: const ['Bands', 'Trend'],
        value: mode,
        onChanged: onModeChanged,
      ),
      footer: _AnalyticsFooter(
        accent: StaffManagementPalette.attendance,
        text:
            '${records.where((item) => item.attendanceRate < 75).length} profiles are below the attendance comfort line.',
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.medium,
        child: SizedBox(
          key: ValueKey(mode + title),
          height: 190,
          child: mode == 'Bands'
              ? StaffDonutChart(
                  slices: [
                    StaffChartSlice(
                      label: 'Excellent',
                      value: records
                          .where((item) => item.attendanceRate >= 90)
                          .length
                          .toDouble(),
                      color: StaffManagementPalette.attendance,
                    ),
                    StaffChartSlice(
                      label: 'Stable',
                      value: records
                          .where(
                            (item) =>
                                item.attendanceRate >= 80 &&
                                item.attendanceRate < 90,
                          )
                          .length
                          .toDouble(),
                      color: StaffManagementPalette.internal,
                    ),
                    StaffChartSlice(
                      label: 'Watch',
                      value: records
                          .where(
                            (item) =>
                                item.attendanceRate >= 70 &&
                                item.attendanceRate < 80,
                          )
                          .length
                          .toDouble(),
                      color: StaffManagementPalette.delegated,
                    ),
                    StaffChartSlice(
                      label: 'Critical',
                      value: records
                          .where((item) => item.attendanceRate < 70)
                          .length
                          .toDouble(),
                      color: StaffManagementPalette.risk,
                    ),
                  ],
                  centerTitle: '${average.round()}%',
                  centerSubtitle: 'Avg attendance',
                )
              : StaffTrendChart(
                  points: _averageTrend(records, attendance: true),
                  color: StaffManagementPalette.attendance,
                ),
        ),
      ),
    );
  }
}

class _EngagementCard extends StatelessWidget {
  const _EngagementCard({
    required this.title,
    required this.subtitle,
    required this.records,
    required this.mode,
    required this.onModeChanged,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final List<StaffAdminRecord> records;
  final String mode;
  final ValueChanged<String> onModeChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return StaffSectionCard(
      title: title,
      subtitle: subtitle,
      accent: accent,
      trailing: StaffSegmentedControl(
        options: const ['Levels', 'Output'],
        value: mode,
        onChanged: onModeChanged,
      ),
      footer: _AnalyticsFooter(
        accent: accent,
        text:
            '${records.where((item) => item.engagementRate >= 80).length} profiles are operating with strong academic activity.',
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.medium,
        child: SizedBox(
          key: ValueKey(mode + title),
          height: 190,
          child: mode == 'Levels'
              ? StaffTrendChart(
                  points: _averageTrend(records, attendance: false),
                  color: accent,
                )
              : StaffBarChart(
                  slices: [
                    StaffChartSlice(
                      label: 'Lectures',
                      value: _averageCount(records, (item) => item.lecturesUploaded),
                      color: accent,
                    ),
                    StaffChartSlice(
                      label: 'Tasks',
                      value: _averageCount(records, (item) => item.tasksCreated),
                      color: StaffManagementPalette.delegated,
                    ),
                    StaffChartSlice(
                      label: 'Posts',
                      value: _averageCount(records, (item) => item.postsCreated),
                      color: AppColors.info,
                    ),
                    StaffChartSlice(
                      label: 'Uploads',
                      value: _averageCount(records, (item) => item.uploadsCount),
                      color: StaffManagementPalette.internal,
                    ),
                  ],
                  maxY: _maxAverageOutput(records) + 2,
                ),
        ),
      ),
    );
  }

  double _maxAverageOutput(List<StaffAdminRecord> records) {
    final values = [
      _averageCount(records, (item) => item.lecturesUploaded),
      _averageCount(records, (item) => item.tasksCreated),
      _averageCount(records, (item) => item.postsCreated),
      _averageCount(records, (item) => item.uploadsCount),
    ];
    return values.fold<double>(0, (max, item) => item > max ? item : max);
  }
}

class _AnimatedAnalyticsCard extends StatelessWidget {
  const _AnimatedAnalyticsCard({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (index * 40)),
      curve: AppMotion.entrance,
      builder: (context, value, inner) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: inner,
          ),
        );
      },
      child: child,
    );
  }
}

class _AnalyticsFooter extends StatelessWidget {
  const _AnalyticsFooter({required this.accent, required this.text});

  final Color accent;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: StaffManagementDecorations.tintedPanel(
        context,
        tint: accent,
        opacity: 0.08,
      ),
      child: Row(
        children: [
          Icon(Icons.insights_rounded, size: 18, color: accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _CompactDropdown extends StatelessWidget {
  const _CompactDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: StaffManagementPalette.muted(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StaffManagementPalette.border(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(18),
          dropdownColor: StaffManagementPalette.surface(context),
          onChanged: onChanged,
          items: [
            for (final item in items)
              DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

List<StaffMetricPoint> _averageTrend(
  List<StaffAdminRecord> records, {
  required bool attendance,
}) {
  if (records.isEmpty) return const [];
  final source = attendance ? records.first.attendanceTrend : records.first.engagementTrend;
  return List.generate(source.length, (index) {
    final average =
        records.fold<double>(
          0,
          (sum, item) => sum +
              (attendance
                  ? item.attendanceTrend[index].value
                  : item.engagementTrend[index].value),
        ) /
        records.length;
    return StaffMetricPoint(label: source[index].label, value: average);
  });
}

double _averageCount(
  List<StaffAdminRecord> records,
  int Function(StaffAdminRecord item) accessor,
) {
  if (records.isEmpty) return 0;
  return records.fold<int>(0, (sum, item) => sum + accessor(item)) /
      records.length;
}
