import 'package:flutter/material.dart';
import 'package:tolab_fci/app/localization/app_localizations.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/permission_model.dart';
import '../../models/role_model.dart';
import '../widgets/matrix_grid.dart';

class PermissionsMatrixScreen extends StatelessWidget {
  const PermissionsMatrixScreen({
    super.key,
    required this.roles,
    required this.permissions,
    required this.pendingCellKeys,
    required this.onPermissionToggle,
  });

  final List<RoleModel> roles;
  final List<PermissionModel> permissions;
  final Set<String> pendingCellKeys;
  final void Function(RoleModel role, PermissionModel permission, bool value)
  onPermissionToggle;

  @override
  Widget build(BuildContext context) {
    final isCompact = AppBreakpoints.isMobile(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;
        final matrix = MatrixGrid(
          roles: roles,
          permissions: permissions,
          pendingCellKeys: pendingCellKeys,
          onCellToggled: onPermissionToggle,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.byValue('Permission Matrix'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.byValue('Toggle granular access across every role with smooth matrix updates.'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  StatusBadge(
                    '${roles.length} ${context.l10n.byValue(roles.length == 1 ? 'role' : 'roles')}',
                    icon: Icons.admin_panel_settings_rounded,
                  ),
                  StatusBadge(
                    '${permissions.length} ${context.l10n.byValue(permissions.length == 1 ? 'permission' : 'permissions')}',
                    icon: Icons.grid_view_rounded,
                  ),
                  if (isCompact)
                    StatusBadge(
                      context.l10n.byValue('Stacked mobile layout'),
                      icon: Icons.phone_iphone_rounded,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (hasBoundedHeight) Expanded(child: matrix) else matrix,
          ],
        );
      },
    );
  }
}
