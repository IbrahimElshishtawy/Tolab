import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tolab_fci/app/localization/app_localizations.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/student_management_models.dart';
import '../../widgets/student_module_charts.dart';
import '../../widgets/student_module_primitives.dart';
import 'student_profile_panel.dart';

class OverviewSection extends StatelessWidget {
  const OverviewSection({
    super.key,
    required this.snapshot,
    required this.selectedStudent,
    required this.notificationStatus,
    required this.onExportCsv,
    required this.onOpenStudent,
    required this.onEditStudent,
    required this.onUploadDocuments,
    required this.onExportTranscript,
    required this.onDownloadBundle,
    required this.onApproveDocument,
    required this.onRejectDocument,
  });

  final StudentModuleSnapshot snapshot;
  final StudentProfile? selectedStudent;
  final String notificationStatus;
  final VoidCallback onExportCsv;
  final ValueChanged<StudentProfile> onOpenStudent;
  final VoidCallback onEditStudent;
  final VoidCallback onUploadDocuments;
  final VoidCallback onExportTranscript;
  final VoidCallback onDownloadBundle;
  final ValueChanged<StudentDocumentRecord> onApproveDocument;
  final ValueChanged<StudentDocumentRecord> onRejectDocument;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final watchlist = snapshot.students.where((item) => item.isAtRisk).length;

    // Localized KPI Cards
    final kpiCards = [
      StudentKpiCard(
        label: context.l10n.byValue('Students'),
        value: snapshot.totalStudents.toString(),
        caption: context.l10n.byValue('All enrolled student records in the module.'),
        icon: Icons.groups_rounded,
        color: AppColors.primary,
      ),
      StudentKpiCard(
        label: context.l10n.byValue('Courses'),
        value: snapshot.activeCoursesCount.toString(),
        caption: context.l10n.byValue('Distinct active offerings assigned to students.'),
        icon: Icons.auto_stories_rounded,
        color: AppColors.info,
      ),
      StudentKpiCard(
        label: context.l10n.byValue('Pending'),
        value: snapshot.pendingApprovals.toString(),
        caption: context.l10n.byValue('Registrations still waiting for admin approval.'),
        icon: Icons.fact_check_rounded,
        color: AppColors.warning,
      ),
      StudentKpiCard(
        label: context.l10n.byValue('Average GPA'),
        value: snapshot.averageGpa.toStringAsFixed(2),
        caption: context.l10n.byValue('Live academic average across all student profiles.'),
        icon: Icons.insights_rounded,
        color: AppColors.success,
      ),
      StudentKpiCard(
        label: context.l10n.byValue('Attendance'),
        value: '${snapshot.averageAttendance.toStringAsFixed(0)}%',
        caption: context.l10n.byValue('Average attendance health tracked from course records.'),
        icon: Icons.co_present_rounded,
        color: AppColors.secondary,
      ),
      StudentKpiCard(
        label: context.l10n.byValue('Pending Docs'),
        value: snapshot.pendingDocuments.toString(),
        caption: context.l10n.byValue('Pending document reviews in the approval queue.'),
        icon: Icons.file_open_rounded,
        color: AppColors.danger,
      ),
    ];

    // Localized charts
    final chart1 = StudentSectionCard(
      title: context.l10n.byValue('Enrollment trend'),
      subtitle: context.l10n.byValue('Realtime line chart for enrollment momentum.'),
      trailing: IconButton(
        onPressed: onExportCsv,
        icon: const Icon(Icons.download_rounded),
      ),
      child: SizedBox(
        height: 260,
        child: StudentLineTrendChart(
          points: snapshot.enrollmentTrend,
        ),
      ),
    );

    final chart2 = StudentSectionCard(
      title: context.l10n.byValue('Department distribution'),
      subtitle: context.l10n.byValue('Student distribution by department'),
      child: SizedBox(
        height: 260,
        child: StudentDepartmentBarChart(
          distribution: snapshot.departmentDistribution,
        ),
      ),
    );

    final chart3 = StudentSectionCard(
      title: context.l10n.byValue('Approval queue'),
      subtitle: context.l10n.byValue('Donut split across pending, active, and watchlist students.'),
      child: SizedBox(
        height: 260,
        child: StudentDonutChart(
          pending: snapshot.pendingApprovals,
          active: snapshot.students
              .where(
                (item) =>
                    item.enrollmentStatus ==
                    StudentEnrollmentStatus.active,
              )
              .length,
          watchlist: watchlist,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Responsive KPI Cards Layout
        if (width >= 900) ...[
          Row(
            children: [
              Expanded(child: kpiCards[0]),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: kpiCards[1]),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: kpiCards[2]),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: kpiCards[3]),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: kpiCards[4]),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: kpiCards[5]),
            ],
          ),
        ] else if (width >= 600) ...[
          Row(
            children: [
              Expanded(child: kpiCards[0]),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: kpiCards[1]),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: kpiCards[2]),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: kpiCards[3]),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: kpiCards[4]),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: kpiCards[5]),
            ],
          ),
        ] else ...[
          kpiCards[0],
          const SizedBox(height: AppSpacing.md),
          kpiCards[1],
          const SizedBox(height: AppSpacing.md),
          kpiCards[2],
          const SizedBox(height: AppSpacing.md),
          kpiCards[3],
          const SizedBox(height: AppSpacing.md),
          kpiCards[4],
          const SizedBox(height: AppSpacing.md),
          kpiCards[5],
        ],
        const SizedBox(height: AppSpacing.lg),

        // Responsive Side-by-Side Charts Layout
        if (width >= 1150) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: chart1),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: chart2),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: chart3),
            ],
          ),
        ] else if (width >= 768) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: chart1),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: chart2),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          chart3,
        ] else ...[
          chart1,
          const SizedBox(height: AppSpacing.md),
          chart2,
          const SizedBox(height: AppSpacing.md),
          chart3,
        ],
        const SizedBox(height: AppSpacing.lg),

        LayoutBuilder(
          builder: (context, constraints) {
            final showSide =
                constraints.maxWidth > 1200 && selectedStudent != null;
            if (!showSide) {
              return Column(
                children: [
                  _PendingQueuesCard(
                    snapshot: snapshot,
                    onOpenStudent: onOpenStudent,
                  ),
                  if (selectedStudent != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    StudentProfilePanel(
                      student: selectedStudent!,
                      onEditStudent: onEditStudent,
                      onUploadDocuments: onUploadDocuments,
                      onExportTranscript: onExportTranscript,
                      onDownloadBundle: onDownloadBundle,
                      onApproveDocument: onApproveDocument,
                      onRejectDocument: onRejectDocument,
                    ),
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _PendingQueuesCard(
                    snapshot: snapshot,
                    onOpenStudent: onOpenStudent,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 4,
                  child: StudentProfilePanel(
                    student: selectedStudent!,
                    onEditStudent: onEditStudent,
                    onUploadDocuments: onUploadDocuments,
                    onExportTranscript: onExportTranscript,
                    onDownloadBundle: onDownloadBundle,
                    onApproveDocument: onApproveDocument,
                    onRejectDocument: onRejectDocument,
                    height: 360,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final alert in snapshot.alerts.take(3))
              SizedBox(
                width: MediaQuery.sizeOf(context).width < 960
                    ? double.infinity
                    : 240,
                child: _AlertTile(alert: alert),
              ),
          ],
        ),
      ],
    );
  }
}

class _PendingQueuesCard extends StatelessWidget {
  const _PendingQueuesCard({
    required this.snapshot,
    required this.onOpenStudent,
  });

  final StudentModuleSnapshot snapshot;
  final ValueChanged<StudentProfile> onOpenStudent;

  @override
  Widget build(BuildContext context) {
    final pending = snapshot.students
        .where(
          (item) =>
              item.enrollmentStatus ==
                  StudentEnrollmentStatus.pendingApproval ||
              item.pendingDocumentCount > 0,
        )
        .toList(growable: false);
    return StudentSectionCard(
      title: context.l10n.byValue('Approvals and document queue'),
      subtitle: context.l10n.byValue(
          'Scrollable approval table highlighting pending enrollment packages, missing document reviews, and at-risk signals.'),
      child: SizedBox(
        height: 360,
        child: DataTable2(
          fixedTopRows: 1,
          minWidth: 860,
          columns: [
            DataColumn2(label: Text(context.l10n.byValue('Student')), size: ColumnSize.L),
            DataColumn2(label: Text(context.l10n.byValue('Department'))),
            DataColumn2(label: Text(context.l10n.byValue('Status'))),
            DataColumn2(label: Text(context.l10n.byValue('Pending docs'))),
            DataColumn2(label: Text(context.l10n.byValue('GPA'))),
            DataColumn2(label: Text(context.l10n.byValue('Action'))),
          ],
          rows: [
            for (final student in pending)
              DataRow2(
                onTap: () => onOpenStudent(student),
                cells: [
                  DataCell(Text(student.fullName)),
                  DataCell(Text(context.l10n.byValue(student.department))),
                  DataCell(
                    StudentStatusPill(
                      label: context.l10n.byValue(student.enrollmentStatus.label),
                      color: student.enrollmentStatus ==
                              StudentEnrollmentStatus.pendingApproval
                          ? AppColors.warning
                          : AppColors.info,
                    ),
                  ),
                  DataCell(Text(student.pendingDocumentCount.toString())),
                  DataCell(Text(student.gpa.toStringAsFixed(2))),
                  const DataCell(Icon(Icons.chevron_right_rounded)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final StudentModuleAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = switch (alert.severity) {
      StudentAlertSeverity.info => AppColors.info,
      StudentAlertSeverity.success => AppColors.success,
      StudentAlertSeverity.warning => AppColors.warning,
      StudentAlertSeverity.critical => AppColors.danger,
    };
    return StudentGlassPanel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StudentStatusPill(label: context.l10n.byValue(alert.badgeLabel), color: color),
              const Spacer(),
              Text(
                DateFormat('HH:mm').format(alert.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(context.l10n.byValue(alert.title), style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(context.l10n.byValue(alert.body), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
