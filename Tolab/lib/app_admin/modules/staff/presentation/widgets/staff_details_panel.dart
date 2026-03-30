import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/staff_admin_models.dart';
import '../charts/staff_analytics_charts.dart';
import '../design/staff_management_tokens.dart';
import 'staff_data_primitives.dart';
import 'staff_permissions_panel.dart';
import 'staff_segmented_control.dart';
import 'staff_status_badge.dart';

class StaffDetailsPanel extends StatefulWidget {
  const StaffDetailsPanel({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onManagePermissions,
    required this.onTogglePermission,
    this.initialTab = 'Overview',
    this.onClose,
  });

  final StaffAdminRecord record;
  final ValueChanged<StaffAdminRecord> onEdit;
  final ValueChanged<StaffAdminRecord> onManagePermissions;
  final void Function(String permissionId, bool enabled) onTogglePermission;
  final String initialTab;
  final VoidCallback? onClose;

  @override
  State<StaffDetailsPanel> createState() => _StaffDetailsPanelState();
}

class _StaffDetailsPanelState extends State<StaffDetailsPanel> {
  late String _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  void didUpdateWidget(covariant StaffDetailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record.id != widget.record.id ||
        oldWidget.initialTab != widget.initialTab) {
      _tab = widget.initialTab;
    }
  }

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
            options: const [
              'Overview',
              'Permissions',
              'Activity',
              'Monitoring',
            ],
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
              _ => _OverviewTab(
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
          StaffAvatarBadge(
            fullName: record.fullName,
            isDoctor: record.isDoctor,
            size: 60,
            radius: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.fullName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.role} • ${record.department} • ${record.employeeId}',
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
                    StaffStatusBadge(record.accountHealthBand),
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
  const _OverviewTab({super.key, required this.record, required this.onEdit});

  final StaffAdminRecord record;
  final ValueChanged<StaffAdminRecord> onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            StaffInfoTile(
              label: 'Email',
              value: record.email,
              icon: Icons.alternate_email_rounded,
              width: 190,
            ),
            StaffInfoTile(
              label: 'Role',
              value: record.role,
              icon: Icons.work_outline_rounded,
              width: 160,
            ),
            StaffInfoTile(
              label: 'Doctor type',
              value: record.roleTypeLabel,
              icon: Icons.badge_outlined,
              width: 190,
            ),
            StaffInfoTile(
              label: 'Department',
              value: record.department,
              icon: Icons.apartment_rounded,
              width: 180,
            ),
            StaffInfoTile(
              label: 'Account status',
              value: record.accountCreationStatus,
              icon: Icons.verified_user_outlined,
              width: 180,
            ),
            StaffInfoTile(
              label: 'Created',
              value: record.createdAtLabel,
              icon: Icons.event_available_outlined,
              width: 180,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Quick metrics',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetricTile(
                label: 'Subjects',
                value: '${record.subjectsAssigned}',
              ),
              _MetricTile(
                label: 'Lectures',
                value: '${record.lecturesUploaded}',
              ),
              _MetricTile(label: 'Tasks', value: '${record.tasksCreated}'),
              _MetricTile(label: 'Posts', value: '${record.postsCreated}'),
              _MetricTile(label: 'Uploads', value: '${record.uploadsCount}'),
              _MetricTile(
                label: 'Permission coverage',
                value: '${record.permissionCoverage.round()}%',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CardBlock(
          title: 'Monitoring pulse',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              SizedBox(
                width: 180,
                child: StaffMetricMeter(
                  value: record.attendanceRate / 100,
                  primary: record.attendanceSummary,
                  secondary: record.attendanceBand,
                  color: StaffManagementPalette.attendance,
                  compact: true,
                ),
              ),
              SizedBox(
                width: 180,
                child: StaffMetricMeter(
                  value: record.engagementRate / 100,
                  primary: record.engagementSummary,
                  secondary: record.engagementBand,
                  color: StaffManagementPalette.engagement,
                  compact: true,
                ),
              ),
              SizedBox(
                width: 180,
                child: StaffInfoTile(
                  label: 'Monitoring summary',
                  value: record.monitoringSummary,
                  icon: Icons.monitor_heart_outlined,
                ),
              ),
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
                  child: StaffSubjectActivityCard(subject: subject),
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
              _MetricTile(
                label: 'Usage summary',
                value: record.activitySummary,
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
                  child: StaffTimelineTile(event: event),
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
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
