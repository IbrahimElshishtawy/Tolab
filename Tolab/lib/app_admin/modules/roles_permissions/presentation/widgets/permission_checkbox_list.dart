import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/permission_model.dart';

class PermissionCheckboxList extends StatelessWidget {
  const PermissionCheckboxList({
    super.key,
    required this.permissions,
    required this.selectedPermissionIds,
    required this.pendingPermissionIds,
    required this.onChanged,
    this.onEdit,
    this.onDelete,
    this.emptyMessage = 'No permissions match the current filters.',
  });

  final List<PermissionModel> permissions;
  final Set<String> selectedPermissionIds;
  final Set<String> pendingPermissionIds;
  final void Function(PermissionModel permission, bool value) onChanged;
  final ValueChanged<PermissionModel>? onEdit;
  final ValueChanged<PermissionModel>? onDelete;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (permissions.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text(
            emptyMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final groupedPermissions = <String, List<PermissionModel>>{};
    for (final permission in permissions) {
      groupedPermissions
          .putIfAbsent(permission.module, () => <PermissionModel>[])
          .add(permission);
    }
    final modules = groupedPermissions.keys.toList(
      growable: false,
    )..sort((left, right) => left.toLowerCase().compareTo(right.toLowerCase()));

    return Column(
      children: [
        for (final module in modules) ...[
          _PermissionModuleSection(
            title: module,
            permissions: groupedPermissions[module]!,
            selectedPermissionIds: selectedPermissionIds,
            pendingPermissionIds: pendingPermissionIds,
            onChanged: onChanged,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          if (module != modules.last) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _PermissionModuleSection extends StatelessWidget {
  const _PermissionModuleSection({
    required this.title,
    required this.permissions,
    required this.selectedPermissionIds,
    required this.pendingPermissionIds,
    required this.onChanged,
    this.onEdit,
    this.onDelete,
  });

  final String title;
  final List<PermissionModel> permissions;
  final Set<String> selectedPermissionIds;
  final Set<String> pendingPermissionIds;
  final void Function(PermissionModel permission, bool value) onChanged;
  final ValueChanged<PermissionModel>? onEdit;
  final ValueChanged<PermissionModel>? onDelete;

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
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusBadge('${permissions.length}', icon: Icons.tune_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < permissions.length; index++) ...[
            _PermissionTile(
              permission: permissions[index],
              selected: selectedPermissionIds.contains(permissions[index].id),
              isBusy: pendingPermissionIds.contains(permissions[index].id),
              onChanged: (value) => onChanged(permissions[index], value),
              onEdit: onEdit == null ? null : () => onEdit!(permissions[index]),
              onDelete: onDelete == null
                  ? null
                  : () => onDelete!(permissions[index]),
            ),
            if (index != permissions.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }
}

class _PermissionTile extends StatefulWidget {
  const _PermissionTile({
    required this.permission,
    required this.selected,
    required this.isBusy,
    required this.onChanged,
    this.onEdit,
    this.onDelete,
  });

  final PermissionModel permission;
  final bool selected;
  final bool isBusy;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<_PermissionTile> createState() => _PermissionTileState();
}

class _PermissionTileState extends State<_PermissionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = widget.selected
        ? AppColors.primary.withValues(alpha: 0.08)
        : _hovered
        ? AppColors.primary.withValues(alpha: 0.04)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.emphasized,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 430;
            final menu = widget.onEdit != null || widget.onDelete != null
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') widget.onEdit?.call();
                      if (value == 'delete') widget.onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      if (widget.onEdit != null)
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit permission'),
                        ),
                      if (widget.onDelete != null)
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete permission'),
                        ),
                    ],
                    icon: const Icon(Icons.more_horiz_rounded),
                  )
                : null;

            final toggle = AnimatedSwitcher(
              duration: AppMotion.fast,
              child: widget.isBusy
                  ? const Padding(
                      key: ValueKey('loading'),
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Checkbox(
                      key: const ValueKey('checkbox'),
                      value: widget.selected,
                      onChanged: (value) => widget.onChanged(value ?? false),
                    ),
            );

            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.permission.name,
                  maxLines: isCompact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                StatusBadge(widget.permission.action.label),
                const SizedBox(height: 6),
                Text(
                  widget.permission.description,
                  maxLines: isCompact ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.permission.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
              ],
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [toggle, const Spacer(), if (menu != null) menu],
                  ),
                  details,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                toggle,
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: details),
                if (menu != null) menu,
              ],
            );
          },
        ),
      ),
    );
  }
}
