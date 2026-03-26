import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/staff_admin_models.dart';
import '../design/staff_management_tokens.dart';
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
  });

  final List<StaffAdminRecord> records;
  final String? selectedId;
  final String sortBy;
  final bool sortAscending;
  final ValueChanged<String> onSort;
  final ValueChanged<StaffAdminRecord> onOpenDetails;
  final ValueChanged<StaffAdminRecord> onEdit;
  final ValueChanged<StaffAdminRecord> onManagePermissions;

  @override
  Widget build(BuildContext context) {
    return StaffSectionCard(
      title: 'Staff directory and monitoring list',
      subtitle:
          'Sortable view of roles, permissions, attendance, engagement, and account status.',
      accent: StaffManagementPalette.engagement,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${records.length} staff',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
          const StaffStatusBadge('Synced'),
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
  });

  final List<StaffAdminRecord> records;
  final String? selectedId;
  final String sortBy;
  final bool sortAscending;
  final ValueChanged<String> onSort;
  final ValueChanged<StaffAdminRecord> onOpenDetails;
  final ValueChanged<StaffAdminRecord> onEdit;
  final ValueChanged<StaffAdminRecord> onManagePermissions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 580,
      child: DataTable2(
        sortColumnIndex: _sortIndex(sortBy),
        sortAscending: sortAscending,
        columnSpacing: 16,
        horizontalMargin: 12,
        dataRowHeight: 86,
        headingRowHeight: 58,
        minWidth: 1360,
        columns: [
          DataColumn2(
            label: const Text('Staff'),
            size: ColumnSize.L,
            onSort: (index, ascending) => onSort('staff'),
          ),
          DataColumn2(
            label: const Text('Role / type'),
            size: ColumnSize.M,
            onSort: (index, ascending) => onSort('role'),
          ),
          DataColumn2(
            label: const Text('Department'),
            onSort: (index, ascending) => onSort('department'),
          ),
          DataColumn2(
            label: const Text('Attendance'),
            onSort: (index, ascending) => onSort('attendance'),
          ),
          DataColumn2(
            label: const Text('Engagement'),
            onSort: (index, ascending) => onSort('engagement'),
          ),
          DataColumn2(
            label: const Text('Permissions'),
            onSort: (index, ascending) => onSort('permissions'),
          ),
          DataColumn2(
            label: const Text('Account'),
            onSort: (index, ascending) => onSort('account'),
          ),
          const DataColumn2(label: Text('Status')),
          const DataColumn2(label: Text('Actions'), size: ColumnSize.S),
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
                    primary: record.department,
                    secondary: '${record.subjectsAssigned} subjects assigned',
                  ),
                ),
                DataCell(
                  _MetricMeter(
                    value: record.attendanceRate / 100,
                    primary: '${record.attendanceRate.round()}%',
                    secondary: record.attendanceRate >= 80
                        ? 'Healthy presence'
                        : 'Needs follow-up',
                    color: StaffManagementPalette.attendance,
                  ),
                ),
                DataCell(
                  _MetricMeter(
                    value: record.engagementRate / 100,
                    primary: '${record.engagementRate.round()}%',
                    secondary:
                        '${record.lecturesUploaded + record.tasksCreated + record.postsCreated} academic outputs',
                    color: StaffManagementPalette.engagement,
                  ),
                ),
                DataCell(
                  _MetricText(
                    primary: record.permissionsSummary,
                    secondary: record.roleSummary,
                  ),
                ),
                DataCell(
                  _MetricText(
                    primary: record.accountCreationStatus,
                    secondary: 'Created ${record.createdAtLabel}',
                  ),
                ),
                DataCell(StaffStatusBadge(record.status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => onOpenDetails(record),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                      ),
                      IconButton(
                        onPressed: () => onEdit(record),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'permissions') {
                            onManagePermissions(record);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<String>(
                            value: 'permissions',
                            child: Text('Manage permissions'),
                          ),
                          PopupMenuItem<String>(
                            value: 'attendance',
                            child: Text('View attendance'),
                          ),
                          PopupMenuItem<String>(
                            value: 'activity',
                            child: Text('Inspect subject activity'),
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
  });

  final List<StaffAdminRecord> records;
  final String? selectedId;
  final ValueChanged<StaffAdminRecord> onOpenDetails;
  final ValueChanged<StaffAdminRecord> onEdit;
  final ValueChanged<StaffAdminRecord> onManagePermissions;

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
                          StaffStatusBadge(record.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          StaffStatusBadge(record.role),
                          StaffStatusBadge(record.roleTypeLabel),
                          _InfoChip(
                            icon: Icons.apartment_rounded,
                            label: record.department,
                          ),
                          _InfoChip(
                            icon: Icons.badge_outlined,
                            label: record.employeeId,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricMeter(
                              value: record.attendanceRate / 100,
                              primary: '${record.attendanceRate.round()}%',
                              secondary: 'attendance',
                              color: StaffManagementPalette.attendance,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _MetricMeter(
                              value: record.engagementRate / 100,
                              primary: '${record.engagementRate.round()}%',
                              secondary: 'engagement',
                              color: StaffManagementPalette.engagement,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricText(
                              primary: record.permissionsSummary,
                              secondary: record.accountCreationStatus,
                            ),
                          ),
                          IconButton(
                            onPressed: () => onEdit(record),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: () => onManagePermissions(record),
                            icon: const Icon(
                              Icons.admin_panel_settings_outlined,
                            ),
                          ),
                          IconButton(
                            onPressed: () => onOpenDetails(record),
                            icon: const Icon(Icons.chevron_right_rounded),
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
    final initials = record.fullName
        .split(' ')
        .take(2)
        .map((part) => part.characters.first)
        .join();
    final gradient = record.isDoctor
        ? const [StaffManagementPalette.doctor, StaffManagementPalette.internal]
        : const [
            StaffManagementPalette.assistant,
            StaffManagementPalette.engagement,
          ];

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            initials,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ),
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
                '${record.email} · ${record.employeeId}',
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
        StaffStatusBadge(record.role),
        StaffStatusBadge(record.roleTypeLabel),
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

class _MetricMeter extends StatelessWidget {
  const _MetricMeter({
    required this.value,
    required this.primary,
    required this.secondary,
    required this.color,
  });

  final double value;
  final String primary;
  final String secondary;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(primary, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 2),
        Text(secondary, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.pillRadius),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
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
          Icon(icon, size: 14, color: StaffManagementPalette.neutral),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
