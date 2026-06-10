import 'package:flutter/material.dart';

import 'package:tolab_fci/app/localization/app_localizations.dart';
import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import 'package:tolab_fci/app_admin/modules/settings/models/settings_models.dart';
import 'package:tolab_fci/app_admin/modules/settings/presentation/settings_screen.dart';
import 'package:tolab_fci/app_admin/modules/settings/widgets/settings_primitives.dart';

class SettingsUserManagementSection extends StatelessWidget {
  const SettingsUserManagementSection({
    super.key,
    required this.vm,
    required this.width,
    required this.onUpdateBundle,
  });

  final SettingsViewModel vm;
  final double width;
  final void Function(SettingsBundle Function(SettingsBundle) update) onUpdateBundle;

  @override
  Widget build(BuildContext context) {
    final userManagement = vm.settingsState.bundle.userManagement;
    return Column(
      children: [
        SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsBlockHeader(
                title: 'Access Defaults',
                subtitle:
                    'Set the default role for new administrators and define how elevated access is approved.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _fieldWrap(
                width: width,
                children: [
                  SettingsDropdownField<String>(
                    value: userManagement.defaultRole,
                    label: 'Default role',
                    items: userManagement.roleTemplates
                        .map((role) => role.name)
                        .toList(growable: false),
                    labelBuilder: (value) => value,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        userManagement: userManagement.copyWith(defaultRole: value),
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Allow staff admin access',
                    subtitle:
                        'Allow staff-facing teams to receive limited admin panel capabilities.',
                    value: userManagement.allowStaffAdminAccess,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        userManagement: userManagement.copyWith(allowStaffAdminAccess: value),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsSwitchTile(
                title: 'Require approval for admin access',
                subtitle:
                    'New admin access changes must be approved by a higher-level role.',
                value: userManagement.requireApprovalForAdminAccess,
                onChanged: (value) => onUpdateBundle(
                  (b) => b.copyWith(
                    userManagement: userManagement.copyWith(requireApprovalForAdminAccess: value),
                  ),
                ),
              ),
              SettingsSwitchTile(
                title: 'Allow role cloning',
                subtitle:
                    'Let admins duplicate an existing permission matrix when creating a new role.',
                value: userManagement.allowRoleCloning,
                onChanged: (value) => onUpdateBundle(
                  (b) => b.copyWith(
                    userManagement: userManagement.copyWith(allowRoleCloning: value),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsBlockHeader(
                title: 'Role Permissions',
                subtitle:
                    'Expand each role template to adjust staff access, admin access, and granular permissions.',
              ),
              const SizedBox(height: AppSpacing.lg),
              for (
                var index = 0;
                index < userManagement.roleTemplates.length;
                index++
              )
                RoleEditorTile(
                  role: userManagement.roleTemplates[index],
                  onRoleChanged: (role) {
                    final nextRoles = [...userManagement.roleTemplates];
                    nextRoles[index] = role;
                    onUpdateBundle(
                      (b) => b.copyWith(
                        userManagement: userManagement.copyWith(roleTemplates: nextRoles),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldWrap({required double width, required List<Widget> children}) {
    final tileWidth = width >= 920 ? (width - AppSpacing.md) / 2 : width;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final child in children)
          SizedBox(width: tileWidth.clamp(280, 640).toDouble(), child: child),
      ],
    );
  }
}

class RoleEditorTile extends StatelessWidget {
  const RoleEditorTile({
    super.key,
    required this.role,
    required this.onRoleChanged,
  });

  final RolePermissionTemplate role;
  final ValueChanged<RolePermissionTemplate> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
        title: Text(context.l10n.byValue(role.name), style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          context.l10n.byValue('${role.permissions.values.where((value) => value).length} active permissions'),
        ),
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: role.adminAccess,
            onChanged: (value) =>
                onRoleChanged(role.copyWith(adminAccess: value)),
            title: Text(context.l10n.byValue('Admin access')),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: role.staffAccess,
            onChanged: (value) =>
                onRoleChanged(role.copyWith(staffAccess: value)),
            title: Text(context.l10n.byValue('Staff access')),
          ),
          for (final entry in role.permissions.entries)
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: entry.value,
              onChanged: (value) {
                final nextPermissions = Map<String, bool>.from(role.permissions)
                  ..[entry.key] = value;
                onRoleChanged(role.copyWith(permissions: nextPermissions));
              },
              title: Text(context.l10n.byValue(entry.key.replaceAll('_', ' '))),
            ),
        ],
      ),
    );
  }
}
