import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../state/app_state.dart';
import '../models/staff_admin_models.dart';
import '../state/staff_state.dart';
import 'forms/staff_account_form.dart';
import 'widgets/staff_analytics_section.dart';
import 'widgets/staff_details_panel.dart';
import 'widgets/staff_feedback_state.dart';
import 'widgets/staff_list_section.dart';
import 'widgets/staff_overview_strip.dart';
import 'widgets/staff_permissions_panel.dart';
import 'widgets/staff_search_actions_panel.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  late final TextEditingController _searchController;

  String _query = '';
  String _roleFilter = 'All staff';
  String _staffScope = 'All staff';
  String _doctorTypeFilter = 'All doctor types';
  String _departmentFilter = 'All departments';
  String _statusFilter = 'All statuses';
  bool _advancedOpen = false;

  String _assistantDepartmentFilter = 'All departments';
  String _doctorAttendanceMode = 'Bands';
  String _doctorEngagementMode = 'Levels';
  String _assistantAttendanceMode = 'Bands';
  String _assistantEngagementMode = 'Levels';

  String _sortBy = 'staff';
  bool _sortAscending = true;
  String? _selectedId;
  String _selectedDetailsTab = 'Overview';

  final Map<String, bool> _permissionOverrides = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, StaffState>(
      onInit: (store) => store.dispatch(LoadStaffAction()),
      converter: (store) => store.state.staffState,
      builder: (context, state) {
        final records = state.items.map(_applyPermissionOverrides).toList();
        final departments = [
          'All departments',
          ...{for (final record in records) record.department},
        ]..sort();
        final filtered = _sortRecords(_filterRecords(records));
        final selected = _resolveSelected(filtered);
        final showDetailsPanel = MediaQuery.sizeOf(context).width >= 1380;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Staff Management',
              subtitle:
                  'Create doctor and teaching assistant accounts, control permissions, monitor attendance, and inspect subject engagement from one premium university operations hub.',
              breadcrumbs: const ['Admin', 'University', 'Staff Management'],
              actions: [
                PremiumButton(
                  label: 'Add doctor',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => _openAccountForm(rolePreset: 'Doctor'),
                ),
                PremiumButton(
                  label: 'Add assistant',
                  icon: Icons.group_add_rounded,
                  isSecondary: true,
                  onPressed: () => _openAccountForm(rolePreset: 'Assistant'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: _buildBody(
                context,
                state: state,
                records: records,
                filtered: filtered,
                departments: departments,
                selected: selected,
                showDetailsPanel: showDetailsPanel,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required StaffState state,
    required List<StaffAdminRecord> records,
    required List<StaffAdminRecord> filtered,
    required List<String> departments,
    required StaffAdminRecord? selected,
    required bool showDetailsPanel,
  }) {
    if (state.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.status == LoadStatus.failure) {
      return StaffFeedbackState(
        title: 'Could not load staff module',
        subtitle: state.errorMessage ?? 'Try refreshing the staff dashboard.',
        icon: Icons.error_outline_rounded,
        action: PremiumButton(
          label: 'Retry',
          icon: Icons.refresh_rounded,
          onPressed: () =>
              StoreProvider.of<AppState>(context).dispatch(LoadStaffAction()),
        ),
      );
    }

    final mainContent = ListView(
      children: [
        StaffOverviewStrip(records: records),
        const SizedBox(height: AppSpacing.lg),
        StaffAnalyticsSection(
          records: records,
          assistantDepartmentFilter: _assistantDepartmentFilter,
          doctorAttendanceMode: _doctorAttendanceMode,
          doctorEngagementMode: _doctorEngagementMode,
          assistantAttendanceMode: _assistantAttendanceMode,
          assistantEngagementMode: _assistantEngagementMode,
          onAssistantDepartmentChanged: (value) =>
              setState(() => _assistantDepartmentFilter = value),
          onDoctorAttendanceModeChanged: (value) =>
              setState(() => _doctorAttendanceMode = value),
          onDoctorEngagementModeChanged: (value) =>
              setState(() => _doctorEngagementMode = value),
          onAssistantAttendanceModeChanged: (value) =>
              setState(() => _assistantAttendanceMode = value),
          onAssistantEngagementModeChanged: (value) =>
              setState(() => _assistantEngagementMode = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        StaffSearchActionsPanel(
          searchController: _searchController,
          query: _query,
          roleFilter: _roleFilter,
          staffScope: _staffScope,
          doctorTypeFilter: _doctorTypeFilter,
          departmentFilter: _departmentFilter,
          statusFilter: _statusFilter,
          departments: departments,
          resultsCount: filtered.length,
          activeFilterCount: _activeFilterCount,
          advancedOpen: _advancedOpen,
          onQueryChanged: (value) => setState(() => _query = value),
          onRoleFilterChanged: (value) => setState(() => _roleFilter = value),
          onScopeChanged: (value) => setState(() => _staffScope = value),
          onDoctorTypeChanged: (value) =>
              setState(() => _doctorTypeFilter = value),
          onDepartmentChanged: (value) =>
              setState(() => _departmentFilter = value),
          onStatusChanged: (value) => setState(() => _statusFilter = value),
          onToggleAdvanced: () =>
              setState(() => _advancedOpen = !_advancedOpen),
          onClear: _clearFilters,
          onAddDoctor: () => _openAccountForm(rolePreset: 'Doctor'),
          onAddAssistant: () => _openAccountForm(rolePreset: 'Assistant'),
          onManagePermissions: () {
            final target = selected ?? filtered.firstOrNull;
            if (target != null) {
              _openPermissionsSheet(target);
            }
          },
          onExport: _handleExport,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (filtered.isEmpty)
          StaffFeedbackState(
            title: 'No staff match these filters',
            subtitle:
                'Adjust the search terms, role type, department, or monitoring scope to bring records back into view.',
            icon: Icons.manage_search_rounded,
            action: PremiumButton(
              label: 'Clear filters',
              icon: Icons.restart_alt_rounded,
              onPressed: _clearFilters,
            ),
          )
        else
          StaffListSection(
            records: filtered,
            selectedId: selected?.id,
            sortBy: _sortBy,
            sortAscending: _sortAscending,
            onSort: _handleSort,
            onOpenDetails: (record) =>
                _handleOpenDetails(record, showDetailsPanel),
            onEdit: (record) => _openAccountForm(record: record),
            onManagePermissions: _openPermissionsSheet,
            onViewAttendance: (record) => _handleOpenDetails(
              record,
              showDetailsPanel,
              initialTab: 'Monitoring',
            ),
            onInspectActivity: (record) => _handleOpenDetails(
              record,
              showDetailsPanel,
              initialTab: 'Activity',
            ),
          ),
      ],
    );

    if (!showDetailsPanel || selected == null) {
      return mainContent;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: mainContent),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 430,
          child: SingleChildScrollView(
            child: StaffDetailsPanel(
              key: ValueKey('${selected.id}:$_selectedDetailsTab'),
              record: selected,
              initialTab: _selectedDetailsTab,
              onEdit: (record) => _openAccountForm(record: record),
              onManagePermissions: _openPermissionsSheet,
              onTogglePermission: (permissionId, enabled) =>
                  _updatePermission(selected.id, permissionId, enabled),
            ),
          ),
        ),
      ],
    );
  }

  int get _activeFilterCount {
    var count = 0;
    if (_query.isNotEmpty) count++;
    if (_roleFilter != 'All staff') count++;
    if (_staffScope != 'All staff') count++;
    if (_doctorTypeFilter != 'All doctor types') count++;
    if (_departmentFilter != 'All departments') count++;
    if (_statusFilter != 'All statuses') count++;
    return count;
  }

  List<StaffAdminRecord> _filterRecords(List<StaffAdminRecord> records) {
    return records.where((record) {
      final queryLower = _query.toLowerCase();
      final matchesQuery =
          _query.isEmpty ||
          record.fullName.toLowerCase().contains(queryLower) ||
          record.email.toLowerCase().contains(queryLower) ||
          record.employeeId.toLowerCase().contains(queryLower) ||
          record.role.toLowerCase().contains(queryLower) ||
          record.roleTypeLabel.toLowerCase().contains(queryLower) ||
          record.department.toLowerCase().contains(queryLower);
      final matchesRole = switch (_roleFilter) {
        'Doctors' => record.isDoctor,
        'Assistants' => record.isAssistant,
        _ => true,
      };
      final matchesDoctorType =
          _doctorTypeFilter == 'All doctor types' ||
          record.doctorType == _doctorTypeFilter ||
          record.isAssistant;
      final matchesDepartment =
          _departmentFilter == 'All departments' ||
          record.department == _departmentFilter;
      final matchesStatus =
          _statusFilter == 'All statuses' || record.status == _statusFilter;
      final matchesScope = switch (_staffScope) {
        'Needs attention' => record.needsAttention,
        'High engagement' => record.engagementRate >= 80,
        'Permissions gaps' => record.permissionCoverage < 75,
        _ => true,
      };
      return matchesQuery &&
          matchesRole &&
          matchesDoctorType &&
          matchesDepartment &&
          matchesStatus &&
          matchesScope;
    }).toList();
  }

  List<StaffAdminRecord> _sortRecords(List<StaffAdminRecord> records) {
    final sorted = [...records];
    sorted.sort((left, right) {
      final factor = _sortAscending ? 1 : -1;
      final result = switch (_sortBy) {
        'role' => '${left.role}${left.roleTypeLabel}'.compareTo(
          '${right.role}${right.roleTypeLabel}',
        ),
        'department' => left.department.compareTo(right.department),
        'attendance' => left.attendanceRate.compareTo(right.attendanceRate),
        'engagement' => left.engagementRate.compareTo(right.engagementRate),
        'permissions' => left.permissionCoverage.compareTo(
          right.permissionCoverage,
        ),
        'account' => left.accountCreationStatus.compareTo(
          right.accountCreationStatus,
        ),
        _ => left.fullName.compareTo(right.fullName),
      };
      return result * factor;
    });
    return sorted;
  }

  StaffAdminRecord? _resolveSelected(List<StaffAdminRecord> records) {
    if (records.isEmpty) return null;
    for (final record in records) {
      if (record.id == _selectedId) return record;
    }
    return records.first;
  }

  StaffAdminRecord _applyPermissionOverrides(StaffAdminRecord record) {
    final groups = [
      for (final group in record.permissionGroups)
        group.copyWith(
          permissions: [
            for (final permission in group.permissions)
              permission.copyWith(
                enabled:
                    _permissionOverrides['${record.id}:${permission.id}'] ??
                    permission.enabled,
              ),
          ],
        ),
    ];

    final totalPermissions = groups.fold<int>(
      0,
      (sum, group) => sum + group.permissions.length,
    );
    final enabledPermissions = groups.fold<int>(
      0,
      (sum, group) =>
          sum +
          group.permissions.where((permission) => permission.enabled).length,
    );

    return record.copyWith(
      permissionGroups: groups,
      permissionCoverage: totalPermissions == 0
          ? 0
          : (enabledPermissions / totalPermissions) * 100,
    );
  }

  void _handleSort(String column) {
    setState(() {
      if (_sortBy == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = column;
        _sortAscending = column == 'staff' || column == 'department';
      }
    });
  }

  void _handleOpenDetails(
    StaffAdminRecord record,
    bool showDetailsPanel, {
    String initialTab = 'Overview',
  }) {
    setState(() {
      _selectedId = record.id;
      _selectedDetailsTab = initialTab;
    });
    if (showDetailsPanel) return;
    _openDetailsSheet(record, initialTab: initialTab);
  }

  void _updatePermission(String staffId, String permissionId, bool enabled) {
    setState(() {
      _permissionOverrides['$staffId:$permissionId'] = enabled;
    });
  }

  void _clearFilters() {
    setState(() {
      _query = '';
      _roleFilter = 'All staff';
      _staffScope = 'All staff';
      _doctorTypeFilter = 'All doctor types';
      _departmentFilter = 'All departments';
      _statusFilter = 'All statuses';
      _advancedOpen = false;
      _sortBy = 'staff';
      _sortAscending = true;
      _selectedDetailsTab = 'Overview';
      _searchController.clear();
    });
  }

  void _handleExport() {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text(
          'Staff export UI is ready for API wiring. Connect this action to CSV or Excel generation when backend support lands.',
        ),
      ),
    );
  }

  Future<void> _openAccountForm({
    StaffAdminRecord? record,
    String? rolePreset,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: AppBreakpoints.isMobile(context) ? 0.96 : 0.92,
        child: StaffAccountFormSheet(record: record, rolePreset: rolePreset),
      ),
    );
  }

  Future<void> _openPermissionsSheet(StaffAdminRecord record) {
    final resolvedRecord = _applyPermissionOverrides(record);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: AppBreakpoints.isMobile(context) ? 0.92 : 0.84,
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permissions management',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${resolvedRecord.fullName} - ${resolvedRecord.role} - ${resolvedRecord.department}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                StaffPermissionsPanel(
                  groups: resolvedRecord.permissionGroups,
                  editable: true,
                  onPermissionChanged: (permissionId, enabled) =>
                      _updatePermission(record.id, permissionId, enabled),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDetailsSheet(
    StaffAdminRecord record, {
    String initialTab = 'Overview',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: AppBreakpoints.isMobile(context) ? 0.96 : 0.90,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          child: StaffDetailsPanel(
            record: _applyPermissionOverrides(record),
            initialTab: initialTab,
            onEdit: (value) => _openAccountForm(record: value),
            onManagePermissions: _openPermissionsSheet,
            onTogglePermission: (permissionId, enabled) =>
                _updatePermission(record.id, permissionId, enabled),
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

extension _ListFirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
