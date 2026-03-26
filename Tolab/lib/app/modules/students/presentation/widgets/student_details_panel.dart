import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/student_admin_models.dart';
import '../charts/students_trend_chart.dart';
import '../design/students_admin_tokens.dart';
import 'students_segmented_control.dart';
import 'students_status_badge.dart';

class StudentDetailsPanel extends StatefulWidget {
  const StudentDetailsPanel({
    super.key,
    required this.student,
    required this.selectedCount,
    this.onClose,
  });

  final StudentAdminRecord student;
  final int selectedCount;
  final VoidCallback? onClose;

  @override
  State<StudentDetailsPanel> createState() => _StudentDetailsPanelState();
}

class _StudentDetailsPanelState extends State<StudentDetailsPanel> {
  String _tab = 'Overview';

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final completion = (student.graduationProgress * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: StudentsAdminDecorations.softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Student profile and control center',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (widget.onClose != null)
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ProfileHero(student: student, completion: completion),
          const SizedBox(height: AppSpacing.lg),
          StudentsSegmentedControl(
            options: const ['Overview', 'Academic', 'Activity', 'Controls'],
            value: _tab,
            onChanged: (value) => setState(() => _tab = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (_tab) {
              'Academic' => _AcademicTab(student: student),
              'Activity' => _ActivityTab(student: student),
              'Controls' => _ControlsTab(
                student: student,
                selectedCount: widget.selectedCount,
              ),
              _ => _OverviewTab(student: student),
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.student, required this.completion});

  final StudentAdminRecord student;
  final int completion;

  @override
  Widget build(BuildContext context) {
    final initials = student.fullName
        .split(' ')
        .take(2)
        .map((part) => part.characters.first)
        .join();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.14),
            AppColors.info.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary,
            child: Text(
              initials,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${student.id} • ${student.department} • ${student.academicLevel}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StudentsStatusBadge(student.status),
                    _SoftPill(
                      icon: Icons.mail_outline_rounded,
                      label: student.email,
                    ),
                    _SoftPill(
                      icon: Icons.timelapse_rounded,
                      label: 'Last active ${student.lastActiveLabel}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _CompletionRing(
            label: 'Graduation',
            value: student.graduationProgress,
            center: '$completion%',
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.student});

  final StudentAdminRecord student;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoGrid(
          items: [
            _InfoItem('National ID', student.nationalId),
            _InfoItem('Phone', student.phone),
            _InfoItem('Batch', student.batch),
            _InfoItem('Section', student.section),
            _InfoItem('Advisor', student.advisorName),
            _InfoItem('Registration', student.registrationWindowLabel),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Quick monitoring snapshot',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetricTile(
                label: 'Term GPA',
                value: student.termGpa.toStringAsFixed(2),
              ),
              _MetricTile(
                label: 'Cumulative GPA',
                value: student.cumulativeGpa.toStringAsFixed(2),
              ),
              _MetricTile(
                label: 'Attendance',
                value: '${student.attendanceRate.round()}%',
              ),
              _MetricTile(
                label: 'Doctor interaction',
                value: '${student.doctorInteractionRate.round()}%',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Permissions and controls',
          child: Column(
            children: [
              for (final permission in student.permissions)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PermissionRow(permission: permission),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AcademicTab extends StatelessWidget {
  const _AcademicTab({required this.student});

  final StudentAdminRecord student;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('academic'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardBlock(
          title: 'Academic tracking',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetricTile(label: 'Quizzes', value: '${student.quizzesTaken}'),
              _MetricTile(label: 'Exams', value: '${student.examsTaken}'),
              _MetricTile(
                label: 'Lectures attended',
                value: '${student.lecturesAttended}/${student.totalLectures}',
              ),
              _MetricTile(label: 'Overall grade', value: student.overallGrade),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Graduation and credits',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LabeledProgress(
                label: 'Graduation progress',
                value: student.graduationProgress,
                trailing:
                    '${student.earnedCreditHours}/${student.totalCreditHours} credits',
              ),
              const SizedBox(height: AppSpacing.sm),
              _LabeledProgress(
                label: 'Current term completion',
                value: student.currentTermProgress,
                trailing: '${(student.currentTermProgress * 100).round()}%',
                color: StudentsAdminPalette.activity,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${student.remainingCreditHours} credit hours remain for graduation.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Current subjects',
          child: Column(
            children: [
              for (final course in student.activeCourses)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _CourseRow(course: course),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Completed subjects',
          child: Column(
            children: [
              for (final course in student.completedCourses)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _CourseRow(course: course, completed: true),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.student});

  final StudentAdminRecord student;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('activity'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardBlock(
          title: 'App activity and engagement',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _MetricTile(
                    label: 'Sessions this week',
                    value: '${student.appSessionsThisWeek}',
                  ),
                  _MetricTile(
                    label: 'Messages with doctors',
                    value: '${student.messagesWithDoctors}',
                  ),
                  _MetricTile(
                    label: 'Subject activity',
                    value: '${student.subjectActivityRate.round()}%',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 180,
                child: StudentsTrendChart(
                  points: student.engagementTrend,
                  color: StudentsAdminPalette.interaction,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Timeline',
          child: Column(
            children: [
              for (final event in student.timeline)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _TimelineRow(event: event),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlsTab extends StatelessWidget {
  const _ControlsTab({required this.student, required this.selectedCount});

  final StudentAdminRecord student;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('controls'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardBlock(
          title: 'Admin actions',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              PremiumButton(
                label: student.registrationAccessSent
                    ? 'Resend registration'
                    : 'Send registration',
                icon: Icons.send_rounded,
                onPressed: () {},
              ),
              const PremiumButton(
                label: 'View permissions',
                icon: Icons.verified_user_outlined,
                isSecondary: true,
              ),
              const PremiumButton(
                label: 'Manage settings',
                icon: Icons.settings_outlined,
                isSecondary: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Course registration flow',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send course registration access from the student profile or trigger it for a wider target group.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  PremiumButton(
                    label: 'Send to ${student.fullName.split(' ').first}',
                    icon: Icons.person_outline_rounded,
                    onPressed: () {},
                  ),
                  PremiumButton(
                    label: 'Send to batch ${student.batch}',
                    icon: Icons.groups_2_outlined,
                    isSecondary: true,
                    onPressed: () {},
                  ),
                  if (selectedCount > 1)
                    PremiumButton(
                      label: 'Send to $selectedCount selected',
                      icon: Icons.mark_email_read_outlined,
                      isSecondary: true,
                      onPressed: () {},
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Permission switches',
          child: Column(
            children: [
              for (final permission in student.permissions)
                SwitchListTile.adaptive(
                  value: permission.enabled,
                  onChanged: (_) {},
                  contentPadding: EdgeInsets.zero,
                  title: Text(permission.title),
                  subtitle: Text(
                    permission.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: StudentsAdminPalette.muted(context),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _CompletionRing extends StatelessWidget {
  const _CompletionRing({
    required this.label,
    required this.value,
    required this.center,
  });

  final String label;
  final double value;
  final String center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(center, style: Theme.of(context).textTheme.titleSmall),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  const _SoftPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.58,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.items});

  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final item in items)
          SizedBox(
            width: 180,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: StudentsAdminPalette.muted(context),
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.value,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);

  final String label;
  final String value;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.permission});

  final StudentPermission permission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            permission.enabled
                ? Icons.check_circle_outline_rounded
                : Icons.lock_outline_rounded,
            color: permission.enabled
                ? StudentsAdminPalette.success
                : StudentsAdminPalette.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permission.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  permission.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          StudentsStatusBadge(permission.enabled ? 'Enabled' : 'Restricted'),
        ],
      ),
    );
  }
}

class _LabeledProgress extends StatelessWidget {
  const _LabeledProgress({
    required this.label,
    required this.value,
    required this.trailing,
    this.color = AppColors.primary,
  });

  final String label;
  final double value;
  final String trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Text(trailing, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.pillRadius),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({required this.course, this.completed = false});

  final StudentCourseProgress course;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${course.code} • ${course.title}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.instructor} • ${course.credits} credits',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StudentsStatusBadge(course.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _LabeledProgress(
            label: completed ? 'Completed score' : 'Course progress',
            value: completed ? 1 : course.progress,
            trailing: completed
                ? '${course.currentMark.round()} mark'
                : '${(course.progress * 100).round()}%',
            color: completed ? StudentsAdminPalette.success : AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event});

  final StudentTimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final color = switch (event.emphasis) {
      'critical' => StudentsAdminPalette.danger,
      'attention' => StudentsAdminPalette.interaction,
      'strong' || 'good' => StudentsAdminPalette.success,
      _ => StudentsAdminPalette.grade,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                        event.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      event.timeLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
