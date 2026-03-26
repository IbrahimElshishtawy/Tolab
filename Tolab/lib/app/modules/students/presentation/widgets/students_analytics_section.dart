import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/student_admin_models.dart';
import '../charts/students_bar_chart.dart';
import '../charts/students_donut_chart.dart';
import '../charts/students_trend_chart.dart';
import '../design/students_admin_tokens.dart';
import 'students_section_card.dart';
import 'students_segmented_control.dart';

class StudentsAnalyticsSection extends StatelessWidget {
  const StudentsAnalyticsSection({
    super.key,
    required this.students,
    required this.gpaMode,
    required this.onGpaModeChanged,
    required this.attendanceScope,
    required this.onAttendanceScopeChanged,
    required this.subjectMode,
    required this.onSubjectModeChanged,
    required this.interactionMode,
    required this.onInteractionModeChanged,
  });

  final List<StudentAdminRecord> students;
  final String gpaMode;
  final ValueChanged<String> onGpaModeChanged;
  final String attendanceScope;
  final ValueChanged<String> onAttendanceScopeChanged;
  final String subjectMode;
  final ValueChanged<String> onSubjectModeChanged;
  final String interactionMode;
  final ValueChanged<String> onInteractionModeChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1480
            ? 4
            : constraints.maxWidth > 980
            ? 2
            : 1;
        final cardWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - ((columns - 1) * AppSpacing.md)) /
                  columns;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(width: cardWidth, child: _buildGradeCard(context)),
            SizedBox(width: cardWidth, child: _buildAttendanceCard(context)),
            SizedBox(width: cardWidth, child: _buildActivityCard(context)),
            SizedBox(width: cardWidth, child: _buildInteractionCard(context)),
          ],
        );
      },
    );
  }

  Widget _buildGradeCard(BuildContext context) {
    final useCumulative = gpaMode == 'Distribution';
    final slices = [
      StudentsChartSlice(
        label: 'A',
        value: students
            .where((item) {
              final gpa = useCumulative ? item.cumulativeGpa : item.termGpa;
              return gpa >= 3.7;
            })
            .length
            .toDouble(),
        color: StudentsAdminPalette.grade,
      ),
      StudentsChartSlice(
        label: 'B',
        value: students
            .where((item) {
              final gpa = useCumulative ? item.cumulativeGpa : item.termGpa;
              return gpa >= 3.0 && gpa < 3.7;
            })
            .length
            .toDouble(),
        color: AppColors.info,
      ),
      StudentsChartSlice(
        label: 'C',
        value: students
            .where((item) {
              final gpa = useCumulative ? item.cumulativeGpa : item.termGpa;
              return gpa >= 2.4 && gpa < 3.0;
            })
            .length
            .toDouble(),
        color: StudentsAdminPalette.interaction,
      ),
      StudentsChartSlice(
        label: 'D',
        value: students
            .where((item) {
              final gpa = useCumulative ? item.cumulativeGpa : item.termGpa;
              return gpa < 2.4;
            })
            .length
            .toDouble(),
        color: StudentsAdminPalette.danger,
      ),
    ];

    final departmentBars = _departmentBarChart(
      students,
      accessor: (item) => useCumulative ? item.cumulativeGpa : item.termGpa,
      colors: const [
        StudentsAdminPalette.grade,
        AppColors.info,
        StudentsAdminPalette.activity,
      ],
    );

    return _AnalyticsCard(
      title: 'GPA and grade levels',
      subtitle:
          'Understand performance bands and academic quality at a glance.',
      trailing: StudentsSegmentedControl(
        options: const ['Distribution', 'Average'],
        value: gpaMode,
        onChanged: onGpaModeChanged,
      ),
      footer: _AnalyticsFootnote(
        accent: StudentsAdminPalette.grade,
        text:
            '${students.where((item) => item.cumulativeGpa >= 3.0).length} students above the 3.0 GPA line.',
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.medium,
        child: SizedBox(
          key: ValueKey(gpaMode),
          height: 192,
          child: gpaMode == 'Distribution'
              ? StudentsDonutChart(
                  slices: slices,
                  centerTitle: students.isEmpty
                      ? '0'
                      : (students.fold<double>(
                                  0,
                                  (sum, item) => sum + item.cumulativeGpa,
                                ) /
                                students.length)
                            .toStringAsFixed(2),
                  centerSubtitle: 'Avg GPA',
                )
              : StudentsBarChart(slices: departmentBars, maxY: 4),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context) {
    final filteredStudents = attendanceScope == 'All'
        ? students
        : students.where((item) => item.department == attendanceScope).toList();

    final slices = [
      StudentsChartSlice(
        label: 'Excellent',
        value: filteredStudents
            .where((item) => item.attendanceRate >= 90)
            .length
            .toDouble(),
        color: StudentsAdminPalette.success,
      ),
      StudentsChartSlice(
        label: 'Stable',
        value: filteredStudents
            .where(
              (item) => item.attendanceRate >= 80 && item.attendanceRate < 90,
            )
            .length
            .toDouble(),
        color: StudentsAdminPalette.attendance,
      ),
      StudentsChartSlice(
        label: 'Watch',
        value: filteredStudents
            .where(
              (item) => item.attendanceRate >= 70 && item.attendanceRate < 80,
            )
            .length
            .toDouble(),
        color: StudentsAdminPalette.interaction,
      ),
      StudentsChartSlice(
        label: 'Critical',
        value: filteredStudents
            .where((item) => item.attendanceRate < 70)
            .length
            .toDouble(),
        color: StudentsAdminPalette.danger,
      ),
    ];

    final scopes = [
      'All',
      ...{for (final item in students) item.department},
    ];

    return _AnalyticsCard(
      title: 'Attendance levels',
      subtitle: 'Segment attendance health across departments and watchlists.',
      trailing: _CompactDropdown<String>(
        value: attendanceScope,
        items: scopes,
        onChanged: (value) =>
            onAttendanceScopeChanged(value ?? attendanceScope),
      ),
      footer: _AnalyticsFootnote(
        accent: StudentsAdminPalette.attendance,
        text:
            '${filteredStudents.where((item) => item.attendanceRate < 75).length} students require attendance intervention.',
      ),
      child: SizedBox(
        height: 192,
        child: StudentsDonutChart(
          slices: slices,
          centerTitle: filteredStudents.isEmpty
              ? '0%'
              : '${(filteredStudents.fold<double>(0, (sum, item) => sum + item.attendanceRate) / filteredStudents.length).round()}%',
          centerSubtitle: 'Avg attendance',
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context) {
    final slices = [
      StudentsChartSlice(
        label: 'Highly active',
        value: students
            .where((item) => item.subjectActivityRate >= 85)
            .length
            .toDouble(),
        color: StudentsAdminPalette.activity,
      ),
      StudentsChartSlice(
        label: 'Healthy',
        value: students
            .where(
              (item) =>
                  item.subjectActivityRate >= 70 &&
                  item.subjectActivityRate < 85,
            )
            .length
            .toDouble(),
        color: StudentsAdminPalette.attendance,
      ),
      StudentsChartSlice(
        label: 'Moderate',
        value: students
            .where(
              (item) =>
                  item.subjectActivityRate >= 55 &&
                  item.subjectActivityRate < 70,
            )
            .length
            .toDouble(),
        color: StudentsAdminPalette.interaction,
      ),
      StudentsChartSlice(
        label: 'Low',
        value: students
            .where((item) => item.subjectActivityRate < 55)
            .length
            .toDouble(),
        color: StudentsAdminPalette.danger,
      ),
    ];

    final completionBars = _departmentBarChart(
      students,
      accessor: (item) => item.currentTermProgress * 100,
      colors: const [
        StudentsAdminPalette.activity,
        StudentsAdminPalette.attendance,
        StudentsAdminPalette.interaction,
      ],
    );

    return _AnalyticsCard(
      title: 'Academic subject activity',
      subtitle:
          'Track coursework engagement, completion pace, and academic energy.',
      trailing: StudentsSegmentedControl(
        options: const ['Activity', 'Completion'],
        value: subjectMode,
        onChanged: onSubjectModeChanged,
      ),
      footer: _AnalyticsFootnote(
        accent: StudentsAdminPalette.activity,
        text:
            '${students.where((item) => item.subjectActivityRate >= 80).length} students are keeping a strong academic rhythm.',
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.medium,
        child: SizedBox(
          key: ValueKey(subjectMode),
          height: 192,
          child: subjectMode == 'Activity'
              ? StudentsDonutChart(
                  slices: slices,
                  centerTitle: students.isEmpty
                      ? '0%'
                      : '${(students.fold<double>(0, (sum, item) => sum + item.subjectActivityRate) / students.length).round()}%',
                  centerSubtitle: 'Avg activity',
                )
              : StudentsBarChart(slices: completionBars, maxY: 100),
        ),
      ),
    );
  }

  Widget _buildInteractionCard(BuildContext context) {
    final strong = students
        .where((item) => item.doctorInteractionRate >= 75)
        .length
        .toDouble();
    final steady = students
        .where(
          (item) =>
              item.doctorInteractionRate >= 55 &&
              item.doctorInteractionRate < 75,
        )
        .length
        .toDouble();
    final weak = students
        .where((item) => item.doctorInteractionRate < 55)
        .length
        .toDouble();
    final averagedTrend = _averageTrend(students);

    return _AnalyticsCard(
      title: 'Doctor interaction and engagement',
      subtitle:
          'Spot healthy communication patterns and students drifting away from instructors.',
      trailing: StudentsSegmentedControl(
        options: const ['Trend', 'Levels'],
        value: interactionMode,
        onChanged: onInteractionModeChanged,
      ),
      footer: _AnalyticsFootnote(
        accent: StudentsAdminPalette.interaction,
        text:
            '${students.where((item) => item.doctorInteractionRate < 55).length} students show weak academic communication.',
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.medium,
        child: SizedBox(
          key: ValueKey(interactionMode),
          height: 192,
          child: interactionMode == 'Trend'
              ? StudentsTrendChart(
                  points: averagedTrend,
                  color: StudentsAdminPalette.interaction,
                )
              : StudentsDonutChart(
                  slices: [
                    StudentsChartSlice(
                      label: 'Strong',
                      value: strong,
                      color: StudentsAdminPalette.success,
                    ),
                    StudentsChartSlice(
                      label: 'Steady',
                      value: steady,
                      color: StudentsAdminPalette.interaction,
                    ),
                    StudentsChartSlice(
                      label: 'Weak',
                      value: weak,
                      color: StudentsAdminPalette.danger,
                    ),
                  ],
                  centerTitle: students.isEmpty
                      ? '0%'
                      : '${(students.fold<double>(0, (sum, item) => sum + item.doctorInteractionRate) / students.length).round()}%',
                  centerSubtitle: 'Avg interaction',
                ),
        ),
      ),
    );
  }

  List<StudentsChartSlice> _departmentBarChart(
    List<StudentAdminRecord> items, {
    required double Function(StudentAdminRecord item) accessor,
    required List<Color> colors,
  }) {
    final grouped = <String, List<StudentAdminRecord>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.department, () => []).add(item);
    }
    var index = 0;
    return grouped.entries.map((entry) {
      final average =
          entry.value.fold<double>(0, (sum, item) => sum + accessor(item)) /
          entry.value.length;
      final slice = StudentsChartSlice(
        label: entry.key.split(' ').first,
        value: average,
        color: colors[index % colors.length],
      );
      index++;
      return slice;
    }).toList();
  }

  List<StudentTrendPoint> _averageTrend(List<StudentAdminRecord> items) {
    if (items.isEmpty) return const [];
    final length = items.first.engagementTrend.length;
    return List.generate(length, (index) {
      final average =
          items.fold<double>(
            0,
            (sum, item) => sum + item.engagementTrend[index].value,
          ) /
          items.length;
      return StudentTrendPoint(
        label: items.first.engagementTrend[index].label,
        value: average,
      );
    });
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.slow,
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
      child: StudentsSectionCard(
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        child: Column(
          children: [
            child,
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.lg),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _AnalyticsFootnote extends StatelessWidget {
  const _AnalyticsFootnote({required this.accent, required this.text});

  final Color accent;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: StudentsAdminDecorations.tintedPanel(
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

class _CompactDropdown<T> extends StatelessWidget {
  const _CompactDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: StudentsAdminPalette.muted(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StudentsAdminPalette.border(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(18),
          dropdownColor: StudentsAdminPalette.surface(context),
          onChanged: onChanged,
          items: [
            for (final item in items)
              DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString(),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
