import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/staff_admin_models.dart';
import '../charts/staff_analytics_charts.dart';
import '../design/staff_management_tokens.dart';
import 'staff_permissions_panel.dart';
import 'staff_section_card.dart';
import 'staff_segmented_control.dart';
import 'staff_status_badge.dart';

class StaffDetailsPanel extends StatefulWidget {
  const StaffDetailsPanel({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onManagePermissions,
    required this.onTogglePermission,
    this.onClose,
  });

  final StaffAdminRecord record;
  final ValueChanged<StaffAdminRecord> onEdit;
  final ValueChanged<StaffAdminRecord> onManagePermissions;
  final void Function(String permissionId, bool enabled) onTogglePermission;
  final VoidCallback? onClose;

  @override
  State<StaffDetailsPanel> createState() => _StaffDetailsPanelState();
}

class _StaffDetailsPanelState extends State<StaffDetailsPanel> {
  String _tab = 'Overview';

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: StaffManagementDecorations.softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Staff control center',
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
          _ProfileHero(record: record),
          const SizedBox(height: AppSpacing.lg),
          StaffSegmentedControl(
            options: const ['Overview', 'Permissions', 'Activity', 'Monitoring'],
            value: _tab,
            onChanged: (value) => setState(() => _tab = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (_tab) {
              'Permissions' => _PermissionsTab(
                  key: const ValueKey('permissions'),
                  record: record,
                  onManagePermissions: widget.onManagePermissions,
                  onTogglePermission: widget.onTogglePermission,
                ),
              'Activity' => _ActivityTab(
                  key: const ValueKey('activity'),
                  record: record,
                ),
              'Monitoring' => _MonitoringTab(
                  key: const ValueKey('monitoring'),
                  record: record,
                  onEdit: widget.onEdit,
                  onManagePermissions: widget.onManagePermissions,
                ),
              _OverviewTab(
                  key: const ValueKey('overview'),
                  record: record,
                  onEdit: widget.onEdit,
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.record});

  final StaffAdminRecord record;

  @override
  Widget build(BuildContext context) {
    final initials = record.fullName
        .split(' ')
        .take(2)
        .map((part) => part.characters.first)
        .join();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            StaffManagementPalette.doctor.withValues(alpha: 0.14),
            StaffManagementPalette.engagement.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(
          color: StaffManagementPalette.doctor.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: StaffManagementPalette.doctor,
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
                Text(record.fullName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${record.role} · ${record.department} · ${record.employeeId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StaffStatusBadge(record.status),
                    StaffStatusBadge(record.roleTypeLabel),
                    StaffStatusBadge('Last active ${record.lastActiveLabel}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _CompletionRing(
            label: 'Attendance',
            value: record.attendanceRate / 100,
            center: '${record.attendanceRate.round()}%',
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    super.key,
    required this.record,
    required this.onEdit,
  });

  final StaffAdminRecord record;
  final ValueChanged<StaffAdminRecord> onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoGrid(
          items: [
            _InfoItem('Email', record.email),
            _InfoItem('Role', record.role),
            _InfoItem('Doctor type', record.roleTypeLabel),
            _InfoItem('Department', record.department),
            _InfoItem('Account status', record.accountCreationStatus),
            _InfoItem('Created', record.createdAtLabel),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Quick metrics',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetricTile(label: 'Subjects', value: '${record.subjectsAssigned}'),
              _MetricTile(label: 'Lectures', value: '${record.lecturesUploaded}'),
              _MetricTile(label: 'Tasks', value: '${record.tasksCreated}'),
              _MetricTile(label: 'Posts', value: '${record.postsCreated}'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Action center',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              PremiumButton(
                label: 'Edit account',
                icon: Icons.edit_outlined,
                onPressed: () => onEdit(record),
              ),
              PremiumButton(
                label: record.status == 'Active' ? 'Deactivate' : 'Reactivate',
                icon: record.status == 'Active'
                    ? Icons.pause_circle_outline_rounded
                    : Icons.restart_alt_rounded,
                isSecondary: true,
                onPressed: () {},
              ),
              const PremiumButton(
                label: 'Review performance',
                icon: Icons.analytics_outlined,
                isSecondary: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PermissionsTab extends StatelessWidget {
  const _PermissionsTab({
    super.key,
    required this.record,
    required this.onManagePermissions,
    required this.onTogglePermission,
  });

  final StaffAdminRecord record;
  final ValueChanged<StaffAdminRecord> onManagePermissions;
  final void Function(String permissionId, bool enabled) onTogglePermission;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Permissions overview',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: () => onManagePermissions(record),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Open full permissions'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        StaffPermissionsPanel(
          groups: record.permissionGroups,
          editable: true,
          onPermissionChanged: onTogglePermission,
        ),
      ],
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({super.key, required this.record});

  final StaffAdminRecord record;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardBlock(
          title: 'Attendance and engagement trends',
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: StaffTrendChart(
                  points: record.attendanceTrend,
                  color: StaffManagementPalette.attendance,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 180,
                child: StaffTrendChart(
                  points: record.engagementTrend,
                  color: StaffManagementPalette.engagement,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Subject interaction tracking',
          child: Column(
            children: [
              for (final subject in record.subjects)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SubjectRow(subject: subject),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonitoringTab extends StatelessWidget {
  const _MonitoringTab({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onManagePermissions,
  });

  final StaffAdminRecord record;
  final ValueChanged<StaffAdminRecord> onEdit;
  final ValueChanged<StaffAdminRecord> onManagePermissions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardBlock(
          title: 'Monitoring snapshot',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetricTile(
                label: 'Permission coverage',
                value: '${record.permissionCoverage.round()}%',
              ),
              _MetricTile(
                label: 'Schedule updates',
                value: '${record.scheduleUpdates}',
              ),
              _MetricTile(label: 'Uploads', value: '${record.uploadsCount}'),
              _MetricTile(
                label: 'Recent activity',
                value: record.recentActivity,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Activity timeline',
          child: Column(
            children: [
              for (final event in record.timeline)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _TimelineRow(event: event),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Admin controls',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              PremiumButton(
                label: 'Edit account',
                icon: Icons.edit_outlined,
                onPressed: () => onEdit(record),
              ),
              PremiumButton(
                label: 'Change permissions',
                icon: Icons.admin_panel_settings_outlined,
                isSecondary: true,
                onPressed: () => onManagePermissions(record),
              ),
              const PremiumButton(
                label: 'Inspect activity',
                icon: Icons.timeline_rounded,
                isSecondary: true,
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
      decoration: StaffManagementDecorations.outline(context),
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
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              backgroundColor: StaffManagementPalette.attendance.withValues(
                alpha: 0.10,
              ),
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
              decoration: StaffManagementDecorations.outline(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(item.value, style: Theme.of(context).textTheme.titleSmall),
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
      width: 146,
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

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.subject});

  final StaffSubjectAssignment subject;

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
                      '${subject.code} · ${subject.title}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.section,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StaffStatusBadge(subject.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StaffStatusBadge('${subject.lectures} lectures'),
              StaffStatusBadge('${subject.tasks} tasks'),
              StaffStatusBadge('${subject.posts} posts'),
              StaffStatusBadge('${subject.uploads} uploads'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.pillRadius),
            child: LinearProgressIndicator(
              value: subject.engagementRate / 100,
              minHeight: 8,
              backgroundColor: StaffManagementPalette.engagement.withValues(
                alpha: 0.12,
              ),
              valueColor: const AlwaysStoppedAnimation<Color>(
                StaffManagementPalette.engagement,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event});

  final StaffTimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final color = switch (event.emphasis) {
      'critical' => StaffManagementPalette.risk,
      'attention' => StaffManagementPalette.delegated,
      'strong' => StaffManagementPalette.attendance,
      _ => StaffManagementPalette.doctor,
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
