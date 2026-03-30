import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/staff_admin_models.dart';
import '../design/staff_management_tokens.dart';
import 'staff_data_primitives.dart';
import 'staff_status_badge.dart';

class StaffPermissionsPanel extends StatelessWidget {
  const StaffPermissionsPanel({
    super.key,
    required this.groups,
    this.editable = false,
    this.onPermissionChanged,
    this.header,
  });

  final List<StaffPermissionGroup> groups;
  final bool editable;
  final void Function(String permissionId, bool enabled)? onPermissionChanged;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
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
    final coverage = totalPermissions == 0
        ? 0.0
        : enabledPermissions / totalPermissions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) ...[header!, const SizedBox(height: AppSpacing.md)],
        StaffMetricMeter(
          value: coverage,
          primary: '${(coverage * 100).round()}% permission coverage',
          secondary:
              '$enabledPermissions of $totalPermissions academic permissions currently enabled',
          color: StaffManagementPalette.doctor,
          compact: true,
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final group in groups)
                  SizedBox(
                    width: compact
                        ? constraints.maxWidth
                        : (constraints.maxWidth - AppSpacing.md) / 2,
                    child: _PermissionGroupCard(
                      group: group,
                      editable: editable,
                      onPermissionChanged: onPermissionChanged,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PermissionGroupCard extends StatelessWidget {
  const _PermissionGroupCard({
    required this.group,
    required this.editable,
    required this.onPermissionChanged,
  });

  final StaffPermissionGroup group;
  final bool editable;
  final void Function(String permissionId, bool enabled)? onPermissionChanged;

  @override
  Widget build(BuildContext context) {
    final enabledCount = group.permissions.where((item) => item.enabled).length;
    final coverage = group.permissions.isEmpty
        ? 0.0
        : enabledCount / group.permissions.length;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: StaffManagementDecorations.outline(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: StaffManagementDecorations.tintedPanel(
                  context,
                  tint: StaffManagementPalette.engagement,
                  opacity: 0.10,
                ),
                alignment: Alignment.center,
                child: Icon(
                  group.icon,
                  color: StaffManagementPalette.engagement,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StaffStatusBadge('$enabledCount active'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          StaffMetricMeter(
            value: coverage,
            primary: '${(coverage * 100).round()}% access coverage',
            secondary: 'Grouped permissions for ${group.title.toLowerCase()}',
            color: StaffManagementPalette.engagement,
            compact: true,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final permission in group.permissions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PermissionTile(
                permission: permission,
                editable: editable,
                onChanged: onPermissionChanged,
              ),
            ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.permission,
    required this.editable,
    required this.onChanged,
  });

  final StaffPermission permission;
  final bool editable;
  final void Function(String permissionId, bool enabled)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: StaffManagementPalette.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permission.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  permission.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (editable)
            Switch.adaptive(
              value: permission.enabled,
              onChanged: (value) => onChanged?.call(permission.id, value),
            )
          else
            StaffStatusBadge(
              permission.enabled ? 'Enabled' : 'Disabled',
              icon: permission.enabled
                  ? Icons.check_circle_outline_rounded
                  : Icons.lock_outline_rounded,
            ),
        ],
      ),
    );
  }
}
