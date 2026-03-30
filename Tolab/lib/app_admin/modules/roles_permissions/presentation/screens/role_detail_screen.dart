import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/permission_model.dart';
import '../../models/role_model.dart';
import '../widgets/permission_checkbox_list.dart';

class RoleDetailScreen extends StatelessWidget {
  const RoleDetailScreen({
    super.key,
    required this.role,
    required this.permissions,
    required this.availableUsers,
    required this.pendingPermissionIds,
    required this.isUsersBusy,
    required this.onEditRole,
    required this.onDeleteRole,
    required this.onAssignUsers,
    required this.onCreatePermission,
    required this.onEditPermission,
    required this.onDeletePermission,
    required this.onTogglePermission,
  });

  final RoleModel? role;
  final List<PermissionModel> permissions;
  final List<RoleUserAssignment> availableUsers;
  final Set<String> pendingPermissionIds;
  final bool isUsersBusy;
  final VoidCallback onEditRole;
  final VoidCallback onDeleteRole;
  final VoidCallback onAssignUsers;
  final VoidCallback onCreatePermission;
  final ValueChanged<PermissionModel> onEditPermission;
  final ValueChanged<PermissionModel> onDeletePermission;
  final void Function(PermissionModel permission, bool value)
  onTogglePermission;

  @override
  Widget build(BuildContext context) {
    if (role == null) {
      return AppCard(
        child: Center(
          child: Text(
            'Select a role to inspect its members, permission coverage, and access matrix.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final selectedPermissionIds = role!.permissionIds.toSet();
    final accent = _colorFromHex(role!.colorHex);
    final isCompact = !AppBreakpoints.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          backgroundColor: accent.withValues(alpha: 0.08),
          borderColor: accent.withValues(alpha: 0.22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.72)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.mediumRadius,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        role!.name.substring(0, 1).toUpperCase(),
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role!.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  StatusBadge(
                    role!.membersLabel,
                    icon: Icons.people_alt_rounded,
                  ),
                  StatusBadge(
                    '${role!.permissionIds.length} permissions',
                    icon: Icons.grid_view_rounded,
                  ),
                  if (role!.isSystem)
                    const StatusBadge('Protected', icon: Icons.lock_rounded),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  PremiumButton(
                    label: 'Edit role',
                    icon: Icons.edit_rounded,
                    isSecondary: true,
                    onPressed: onEditRole,
                  ),
                  PremiumButton(
                    label: isUsersBusy ? 'Updating users...' : 'Assign users',
                    icon: Icons.person_add_alt_1_rounded,
                    onPressed: isUsersBusy ? null : onAssignUsers,
                  ),
                  PremiumButton(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    isSecondary: true,
                    isDestructive: true,
                    onPressed: role!.isSystem ? null : onDeleteRole,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isCompact)
          Column(
            children: [
              _AssignedUsersCard(
                role: role!,
                availableUsers: availableUsers,
                onAssignUsers: onAssignUsers,
              ),
              const SizedBox(height: AppSpacing.lg),
              _PermissionsCard(
                permissions: permissions,
                selectedPermissionIds: selectedPermissionIds,
                pendingPermissionIds: pendingPermissionIds,
                onCreatePermission: onCreatePermission,
                onEditPermission: onEditPermission,
                onDeletePermission: onDeletePermission,
                onTogglePermission: onTogglePermission,
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: _AssignedUsersCard(
                  role: role!,
                  availableUsers: availableUsers,
                  onAssignUsers: onAssignUsers,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 6,
                child: _PermissionsCard(
                  permissions: permissions,
                  selectedPermissionIds: selectedPermissionIds,
                  pendingPermissionIds: pendingPermissionIds,
                  onCreatePermission: onCreatePermission,
                  onEditPermission: onEditPermission,
                  onDeletePermission: onDeletePermission,
                  onTogglePermission: onTogglePermission,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _AssignedUsersCard extends StatelessWidget {
  const _AssignedUsersCard({
    required this.role,
    required this.availableUsers,
    required this.onAssignUsers,
  });

  final RoleModel role;
  final List<RoleUserAssignment> availableUsers;
  final VoidCallback onAssignUsers;

  @override
  Widget build(BuildContext context) {
    final selectedUsers = availableUsers
        .where((user) => role.userIds.contains(user.id))
        .toList(growable: false);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Assigned Users',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: onAssignUsers,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (selectedUsers.isEmpty)
            Text(
              'This role is not assigned to any users yet.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Column(
              children: [
                for (var index = 0; index < selectedUsers.length; index++) ...[
                  _AssignedUserTile(user: selectedUsers[index]),
                  if (index != selectedUsers.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Divider(height: 1),
                    ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _AssignedUserTile extends StatelessWidget {
  const _AssignedUserTile({required this.user});

  final RoleUserAssignment user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            user.initials,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                '${user.email} - ${user.department}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard({
    required this.permissions,
    required this.selectedPermissionIds,
    required this.pendingPermissionIds,
    required this.onCreatePermission,
    required this.onEditPermission,
    required this.onDeletePermission,
    required this.onTogglePermission,
  });

  final List<PermissionModel> permissions;
  final Set<String> selectedPermissionIds;
  final Set<String> pendingPermissionIds;
  final VoidCallback onCreatePermission;
  final ValueChanged<PermissionModel> onEditPermission;
  final ValueChanged<PermissionModel> onDeletePermission;
  final void Function(PermissionModel permission, bool value)
  onTogglePermission;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role Permissions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grant or revoke module access using grouped, animated checkboxes.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PremiumButton(
                label: 'Add permission',
                icon: Icons.add_rounded,
                onPressed: onCreatePermission,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PermissionCheckboxList(
          permissions: permissions,
          selectedPermissionIds: selectedPermissionIds,
          pendingPermissionIds: pendingPermissionIds,
          onChanged: onTogglePermission,
          onEdit: onEditPermission,
          onDelete: onDeletePermission,
        ),
      ],
    );
  }
}

Color _colorFromHex(String hex) {
  final value = hex.replaceAll('#', '');
  final normalized = value.length == 6 ? 'FF$value' : value;
  return Color(int.tryParse(normalized, radix: 16) ?? 0xFF2563EB);
}
