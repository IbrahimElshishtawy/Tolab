import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:tolab_fci/app/localization/app_localizations.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/staff_admin_models.dart';
import '../design/staff_management_tokens.dart';
import 'staff_data_primitives.dart';
import 'staff_section_card.dart';
import 'staff_status_badge.dart';

class StaffListSection extends StatelessWidget {
  const StaffListSection({
    super.key,
    required this.records,
    required this.selectedId,
    required this.sortBy,
    required this.sortAscending,
    required this.onSort,
    required this.onOpenDetails,
    required this.onEdit,
    required this.onManagePermissions,
    required this.onViewAttendance,
    required this.onInspectActivity,
  });

  final List<StaffAdminRecord> records;
  final String? selectedId;
  final String sortBy;
  final bool sortAscending;
  final ValueChanged<String> onSort;
  final ValueChanged<StaffAdminRecord> onOpenDetails;
  final ValueChanged<StaffAdminRecord> onEdit;
  final ValueChanged<StaffAdminRecord> onManagePermissions;
  final ValueChanged<StaffAdminRecord> onViewAttendance;
  final ValueChanged<StaffAdminRecord> onInspectActivity;

  @override
  Widget build(BuildContext context) {
    return StaffSectionCard(
      title: context.l10n.byValue('Staff directory and monitoring list'),
      subtitle: context.l10n.byValue(
          'Sortable view of roles, permissions, attendance, engagement, and account status.'),
      accent: StaffManagementPalette.engagement,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${records.length} ${context.l10n.byValue('staff')}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
          StaffStatusBadge(context.l10n.byValue('Synced')),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useCards = constraints.maxWidth < 1080;
          return useCards
              ? _StaffCardList(
                  records: records,
                  selectedId: selectedId,
                  onOpenDetails: onOpenDetails,
                  onEdit: onEdit,
                  onManagePermissions: onManagePermissions,
                  onViewAttendance: onViewAttendance,
                  onInspectActivity: onInspectActivity,
                )
              : _StaffTable(
                  records: records,
                  selectedId: selectedId,
                  sortBy: sortBy,
                  sortAscending: sortAscending,
                  onSort: onSort,
                  onOpenDetails: onOpenDetails,
                  onEdit: onEdit,
                  onManagePermissions: onManagePermissions,
                  onViewAttendance: onViewAttendance,
                  onInspectActivity: onInspectActivity,
                );
        },
      ),
    );
  }
}

class _StaffTable extends StatelessWidget {
  const _StaffTable({
    required this.records,
    required this.selectedId,
    required this.sortBy,
    required this.sortAscending,
    required this.onSort,
    required this.onOpenDetails,
    required this.onEdit,
    required this.onManagePermissions,
    required this.onViewAttendance,
    required this.onInspectActivity,
  });

  final List<StaffAdminRecord> records;
  final String? selectedId;
  final String sortBy;
  final bool sortAscending;
  final ValueChanged<String> onSort;
  final ValueChanged<StaffAdminRecord> onOpenDetails;
  final ValueChanged<StaffAdminRecord> onEdit;
  final ValueChanged<StaffAdminRecord> onManagePermissions;
  final ValueChanged<StaffAdminRecord> onViewAttendance;
  final ValueChanged<StaffAdminRecord> onInspectActivity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 580,
      child: DataTable2(
        sortColumnIndex: _sortIndex(sortBy),
        sortAscending: sortAscending,
        columnSpacing: 16,
        horizontalMargin: 12,
        dataRowHeight: 98,
        headingRowHeight: 58,
        minWidth: 1400,
        columns: [
          DataColumn2(
            label: Text(context.l10n.byValue('Staff')),
            size: ColumnSize.L,
            onSort: (index, ascending) => onSort('staff'),
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Role / type')),
            size: ColumnSize.M,
            onSort: (index, ascending) => onSort('role'),
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Department')),
            onSort: (index, ascending) => onSort('department'),
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Attendance')),
            size: ColumnSize.L,
            onSort: (index, ascending) => onSort('attendance'),
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Engagement')),
            size: ColumnSize.L,
            onSort: (index, ascending) => onSort('engagement'),
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Permissions')),
            onSort: (index, ascending) => onSort('permissions'),
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Account')),
            onSort: (index, ascending) => onSort('account'),
          ),
          DataColumn2(label: Text(context.l10n.byValue('Status'))),
          DataColumn2(label: Text(context.l10n.byValue('Actions')), size: ColumnSize.S),
        ],
        rows: [
          for (final record in records)
            DataRow2(
              selected: record.id == selectedId,
              onTap: () => onOpenDetails(record),
              color: WidgetStatePropertyAll(
                record.id == selectedId
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
              cells: [
                DataCell(_IdentityCell(record: record)),
                DataCell(_RoleCell(record: record)),
                DataCell(
                  _MetricText(
                    primary: context.l10n.byValue(record.department),
                    secondary: '${record.subjectsAssigned} ${context.l10n.byValue('subjects assigned')}',
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 170,
                    child: StaffMetricMeter(
                      value: record.attendanceRate / 100,
                      primary: '${record.attendanceRate.round()}%',
                      secondary: record.attendanceRate >= 80
                          ? context.l10n.byValue('Healthy presence')
                          : context.l10n.byValue('Needs follow-up'),
                      color: StaffManagementPalette.attendance,
                      compact: true,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 180,
                    child: StaffMetricMeter(
                      value: record.engagementRate / 100,
                      primary: '${record.engagementRate.round()}%',
                      secondary:
                          '${record.lecturesUploaded + record.tasksCreated + record.postsCreated} ${context.l10n.byValue('academic outputs')}',
                      color: StaffManagementPalette.engagement,
                      compact: true,
                    ),
                  ),
                ),
                DataCell(
                  _MetricText(
                    primary: context.l10n.byValue(record.permissionsSummary),
                    secondary: context.l10n.byValue(record.roleSummary),
                  ),
                ),
                DataCell(
                  _MetricText(
                    primary: context.l10n.byValue(record.accountCreationStatus),
                    secondary: '${context.l10n.byValue('Created')} ${record.createdAtLabel}',
                  ),
                ),
                DataCell(StaffStatusBadge(context.l10n.byValue(record.status))),
                DataCell(
                  Row(
                    children: [
                      StaffActionIconButton(
                        onPressed: () => onOpenDetails(record),
                        icon: Icons.visibility_outlined,
                        tooltip: context.l10n.byValue('Open details'),
                      ),
                      StaffActionIconButton(
                        onPressed: () => onEdit(record),
                        icon: Icons.edit_outlined,
                        tooltip: context.l10n.byValue('Edit account'),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'permissions') {
                            onManagePermissions(record);
                          } else if (value == 'attendance') {
                            onViewAttendance(record);
                          } else if (value == 'activity') {
                            onInspectActivity(record);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'permissions',
                            child: Text(context.l10n.byValue('Manage permissions')),
                          ),
                          PopupMenuItem<String>(
                            value: 'attendance',
                            child: Text(context.l10n.byValue('View attendance')),
                          ),
                          PopupMenuItem<String>(
                            value: 'activity',
                            child: Text(context.l10n.byValue('Inspect subject activity')),
                          ),
                        ],
                        icon: const Icon(Icons.more_horiz_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  int? _sortIndex(String key) {
    return switch (key) {
      'staff' => 0,
      'role' => 1,
      'department' => 2,
      'attendance' => 3,
      'engagement' => 4,
      'permissions' => 5,
      'account' => 6,
      _ => null,
    };
  }
}

class _StaffCardList extends StatelessWidget {
  const _StaffCardList({
    required this.records,
    required this.selectedId,
    required this.onOpenDetails,
    required this.onEdit,
    required this.onManagePermissions,
    required this.onViewAttendance,
    required this.onInspectActivity,
  });

  final List<StaffAdminRecord> records;
  final String? selectedId;
  final ValueChanged<StaffAdminRecord> onOpenDetails;
  final ValueChanged<StaffAdminRecord> onEdit;
  final ValueChanged<StaffAdminRecord> onManagePermissions;
  final ValueChanged<StaffAdminRecord> onViewAttendance;
  final ValueChanged<StaffAdminRecord> onInspectActivity;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final record = records[index];
        final selected = record.id == selectedId;
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 280),
          child: SlideAnimation(
            verticalOffset: 16,
            child: FadeInAnimation(
              child: InkWell(
                onTap: () => onOpenDetails(record),
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : StaffManagementPalette.muted(context),
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : StaffManagementPalette.border(context),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _IdentityCell(record: record)),
                          const SizedBox(width: AppSpacing.sm),
                          StaffStatusBadge(context.l10n.byValue(record.status)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          StaffStatusBadge(context.l10n.byValue(record.role)),
                          StaffStatusBadge(context.l10n.byValue(record.roleTypeLabel)),
                          _InfoChip(
                            icon: Icons.apartment_rounded,
                            label: context.l10n.byValue(record.department),
                          ),
                          _InfoChip(
                            icon: Icons.badge_outlined,
                            label: record.employeeId,
                          ),
                          _InfoChip(
                            icon: Icons.monitor_heart_outlined,
                            label: context.l10n.byValue(record.accountHealthBand),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: StaffMetricMeter(
                              value: record.attendanceRate / 100,
                              primary: '${record.attendanceRate.round()}%',
                              secondary: context.l10n.byValue('attendance'),
                              color: StaffManagementPalette.attendance,
                              compact: true,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: StaffMetricMeter(
                              value: record.engagementRate / 100,
                              primary: '${record.engagementRate.round()}%',
                              secondary: context.l10n.byValue('engagement'),
                              color: StaffManagementPalette.engagement,
                              compact: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          SizedBox(
                            width: 180,
                            child: _MetricText(
                              primary: context.l10n.byValue(record.permissionsSummary),
                              secondary: context.l10n.byValue(record.accountCreationStatus),
                            ),
                          ),
                          StaffActionIconButton(
                            onPressed: () => onEdit(record),
                            icon: Icons.edit_outlined,
                            tooltip: context.l10n.byValue('Edit account'),
                          ),
                          StaffActionIconButton(
                            onPressed: () => onManagePermissions(record),
                            icon: Icons.admin_panel_settings_outlined,
                            tooltip: context.l10n.byValue('Manage permissions'),
                          ),
                          StaffActionIconButton(
                            onPressed: () => onViewAttendance(record),
                            icon: Icons.fact_check_outlined,
                            tooltip: context.l10n.byValue('View attendance'),
                          ),
                          StaffActionIconButton(
                            onPressed: () => onInspectActivity(record),
                            icon: Icons.timeline_rounded,
                            tooltip: context.l10n.byValue('Inspect activity'),
                          ),
                          StaffActionIconButton(
                            onPressed: () => onOpenDetails(record),
                            icon: Icons.chevron_right_rounded,
                            tooltip: context.l10n.byValue('Open details'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IdentityCell extends StatelessWidget {
  const _IdentityCell({required this.record});

  final StaffAdminRecord record;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StaffAvatarBadge(fullName: record.fullName, isDoctor: record.isDoctor),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                record.fullName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text(
                '${record.email} • ${record.employeeId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleCell extends StatelessWidget {
  const _RoleCell({required this.record});

  final StaffAdminRecord record;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        StaffStatusBadge(context.l10n.byValue(record.role)),
        StaffStatusBadge(context.l10n.byValue(record.roleTypeLabel)),
      ],
    );
  }
}

class _MetricText extends StatelessWidget {
  const _MetricText({required this.primary, required this.secondary});

  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(primary, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 2),
        Text(secondary, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(color: StaffManagementPalette.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: StaffManagementPalette.subtleText(context),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
