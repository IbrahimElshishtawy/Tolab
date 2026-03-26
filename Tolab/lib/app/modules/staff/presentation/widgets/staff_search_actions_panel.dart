import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../design/staff_management_tokens.dart';
import 'staff_section_card.dart';
import 'staff_segmented_control.dart';
import 'staff_status_badge.dart';

class StaffSearchActionsPanel extends StatelessWidget {
  const StaffSearchActionsPanel({
    super.key,
    required this.searchController,
    required this.query,
    required this.roleFilter,
    required this.staffScope,
    required this.doctorTypeFilter,
    required this.departmentFilter,
    required this.statusFilter,
    required this.departments,
    required this.resultsCount,
    required this.activeFilterCount,
    required this.advancedOpen,
    required this.onQueryChanged,
    required this.onRoleFilterChanged,
    required this.onScopeChanged,
    required this.onDoctorTypeChanged,
    required this.onDepartmentChanged,
    required this.onStatusChanged,
    required this.onToggleAdvanced,
    required this.onClear,
    required this.onAddDoctor,
    required this.onAddAssistant,
    required this.onManagePermissions,
  });

  final TextEditingController searchController;
  final String query;
  final String roleFilter;
  final String staffScope;
  final String doctorTypeFilter;
  final String departmentFilter;
  final String statusFilter;
  final List<String> departments;
  final int resultsCount;
  final int activeFilterCount;
  final bool advancedOpen;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onRoleFilterChanged;
  final ValueChanged<String> onScopeChanged;
  final ValueChanged<String> onDoctorTypeChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onToggleAdvanced;
  final VoidCallback onClear;
  final VoidCallback onAddDoctor;
  final VoidCallback onAddAssistant;
  final VoidCallback onManagePermissions;

  @override
  Widget build(BuildContext context) {
    return StaffSectionCard(
      title: 'Search, filters, and actions',
      subtitle:
          'Search by full name, email, staff ID, role, or department while keeping account actions within immediate reach.',
      accent: StaffManagementPalette.doctor,
      trailing: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        alignment: WrapAlignment.end,
        children: [
          PremiumButton(
            label: 'Add doctor',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: onAddDoctor,
          ),
          PremiumButton(
            label: 'Add assistant',
            icon: Icons.group_add_rounded,
            isSecondary: true,
            onPressed: onAddAssistant,
          ),
          PremiumButton(
            label: 'Manage permissions',
            icon: Icons.admin_panel_settings_outlined,
            isSecondary: true,
            onPressed: onManagePermissions,
          ),
          const PremiumButton(
            label: 'Export',
            icon: Icons.download_rounded,
            isSecondary: true,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StaffStatusBadge('$resultsCount results'),
              StaffStatusBadge(
                activeFilterCount == 0
                    ? 'No active filters'
                    : '$activeFilterCount active filters',
              ),
              StaffStatusBadge(roleFilter),
              if (departmentFilter != 'All departments')
                StaffStatusBadge(departmentFilter),
              if (statusFilter != 'All statuses') StaffStatusBadge(statusFilter),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 980;
              final searchWidth =
                  compact ? constraints.maxWidth : constraints.maxWidth * 0.34;
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  SizedBox(
                    width: searchWidth,
                    child: TextField(
                      controller: searchController,
                      onChanged: onQueryChanged,
                      decoration: const InputDecoration(
                        hintText:
                            'Search by full name, email, staff ID, role type, department',
                        prefixIcon: Icon(Icons.search_rounded),
                        suffixIcon: Icon(Icons.manage_search_rounded),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: compact ? constraints.maxWidth : 180,
                    child: _FilterDropdown(
                      label: 'Role',
                      value: roleFilter,
                      items: const ['All staff', 'Doctors', 'Assistants'],
                      onChanged: onRoleFilterChanged,
                    ),
                  ),
                  SizedBox(
                    width: compact ? constraints.maxWidth : 220,
                    child: _FilterDropdown(
                      label: 'Doctor type',
                      value: doctorTypeFilter,
                      items: const [
                        'All doctor types',
                        'Internal faculty doctor',
                        'Delegated / external doctor',
                      ],
                      onChanged: onDoctorTypeChanged,
                    ),
                  ),
                  SizedBox(
                    width: compact ? constraints.maxWidth : 220,
                    child: _FilterDropdown(
                      label: 'Department',
                      value: departmentFilter,
                      items: departments,
                      onChanged: onDepartmentChanged,
                    ),
                  ),
                  SizedBox(
                    width: compact ? constraints.maxWidth : 170,
                    child: _FilterDropdown(
                      label: 'Status',
                      value: statusFilter,
                      items: const ['All statuses', 'Active', 'Inactive'],
                      onChanged: onStatusChanged,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StaffSegmentedControl(
                options: const [
                  'All staff',
                  'Needs attention',
                  'High engagement',
                  'Permissions gaps',
                ],
                value: staffScope,
                onChanged: onScopeChanged,
              ),
              OutlinedButton.icon(
                onPressed: onToggleAdvanced,
                style: StaffManagementButtons.subtle(
                  context,
                  tint: AppColors.info,
                ),
                icon: Icon(
                  advancedOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.tune_rounded,
                  size: 18,
                ),
                label: Text(advancedOpen ? 'Hide advanced' : 'Advanced filter'),
              ),
              OutlinedButton.icon(
                onPressed: onClear,
                style: StaffManagementButtons.subtle(
                  context,
                  tint: StaffManagementPalette.neutral,
                ),
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Clear filters'),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: advancedOpen
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: StaffManagementDecorations.outline(context),
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: const [
                          _AdvancedChip(label: 'Attendance below 70%'),
                          _AdvancedChip(label: 'Delegated doctors only'),
                          _AdvancedChip(label: 'Invite pending'),
                          _AdvancedChip(label: 'Low permissions coverage'),
                          _AdvancedChip(label: 'High content output'),
                          _AdvancedChip(label: 'Inactive accounts'),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in items)
          DropdownMenuItem<String>(value: item, child: Text(item)),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}

class _AdvancedChip extends StatelessWidget {
  const _AdvancedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(color: StaffManagementPalette.border(context)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
