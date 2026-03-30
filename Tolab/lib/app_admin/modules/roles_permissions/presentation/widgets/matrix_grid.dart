import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/permission_model.dart';
import '../../models/role_model.dart';

class MatrixGrid extends StatelessWidget {
  const MatrixGrid({
    super.key,
    required this.roles,
    required this.permissions,
    required this.pendingCellKeys,
    required this.onCellToggled,
  });

  final List<RoleModel> roles;
  final List<PermissionModel> permissions;
  final Set<String> pendingCellKeys;
  final void Function(RoleModel role, PermissionModel permission, bool value)
  onCellToggled;

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty || permissions.isEmpty) {
      return AppCard(
        child: Center(
          child: Text(
            'Roles and permissions need data before the matrix can render.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (AppBreakpoints.isMobile(context)) {
      return Column(
        children: [
          for (var index = 0; index < permissions.length; index++) ...[
            _MobilePermissionCard(
              permission: permissions[index],
              roles: roles,
              pendingCellKeys: pendingCellKeys,
              onCellToggled: onCellToggled,
            ),
            if (index != permissions.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 360 + (roles.length * 176)),
          child: Column(
            children: [
              _MatrixHeader(roles: roles),
              for (var index = 0; index < permissions.length; index++)
                _MatrixRow(
                  permission: permissions[index],
                  roles: roles,
                  pendingCellKeys: pendingCellKeys,
                  striped: index.isOdd,
                  onCellToggled: onCellToggled,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatrixHeader extends StatelessWidget {
  const _MatrixHeader({required this.roles});

  final List<RoleModel> roles;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.cardRadius),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 360,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Permission',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          for (final role in roles)
            SizedBox(
              width: 176,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.membersLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MatrixRow extends StatefulWidget {
  const _MatrixRow({
    required this.permission,
    required this.roles,
    required this.pendingCellKeys,
    required this.striped,
    required this.onCellToggled,
  });

  final PermissionModel permission;
  final List<RoleModel> roles;
  final Set<String> pendingCellKeys;
  final bool striped;
  final void Function(RoleModel role, PermissionModel permission, bool value)
  onCellToggled;

  @override
  State<_MatrixRow> createState() => _MatrixRowState();
}

class _MatrixRowState extends State<_MatrixRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _hovered
        ? AppColors.primary.withValues(alpha: 0.06)
        : widget.striped
        ? AppColors.primary.withValues(alpha: 0.02)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.emphasized,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 360,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.permission.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        StatusBadge(widget.permission.action.label),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.permission.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            for (final role in widget.roles)
              SizedBox(
                width: 176,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _MatrixCell(
                    role: role,
                    permission: widget.permission,
                    isBusy: widget.pendingCellKeys.contains(
                      _cellKey(role.id, widget.permission.id),
                    ),
                    enabled: role.permissionIds.contains(widget.permission.id),
                    onChanged: (value) =>
                        widget.onCellToggled(role, widget.permission, value),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MatrixCell extends StatelessWidget {
  const _MatrixCell({
    required this.role,
    required this.permission,
    required this.enabled,
    required this.isBusy,
    required this.onChanged,
  });

  final RoleModel role;
  final PermissionModel permission;
  final bool enabled;
  final bool isBusy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.primary.withValues(alpha: 0.08)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.2)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isBusy)
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Checkbox(
              value: enabled,
              onChanged: (value) => onChanged(value ?? false),
            ),
        ],
      ),
    );
  }
}

class _MobilePermissionCard extends StatelessWidget {
  const _MobilePermissionCard({
    required this.permission,
    required this.roles,
    required this.pendingCellKeys,
    required this.onCellToggled,
  });

  final PermissionModel permission;
  final List<RoleModel> roles;
  final Set<String> pendingCellKeys;
  final void Function(RoleModel role, PermissionModel permission, bool value)
  onCellToggled;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  permission.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusBadge(permission.action.label),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            permission.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final role in roles)
                AnimatedContainer(
                  duration: AppMotion.fast,
                  curve: AppMotion.emphasized,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: role.permissionIds.contains(permission.id)
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(
                      AppConstants.pillRadius,
                    ),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      AppConstants.pillRadius,
                    ),
                    onTap:
                        pendingCellKeys.contains(
                          _cellKey(role.id, permission.id),
                        )
                        ? null
                        : () => onCellToggled(
                            role,
                            permission,
                            !role.permissionIds.contains(permission.id),
                          ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        pendingCellKeys.contains(
                              _cellKey(role.id, permission.id),
                            )
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                role.permissionIds.contains(permission.id)
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 16,
                                color:
                                    role.permissionIds.contains(permission.id)
                                    ? AppColors.primary
                                    : Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                              ),
                        const SizedBox(width: 6),
                        Text(
                          role.name,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _cellKey(String roleId, String permissionId) => '$roleId::$permissionId';
