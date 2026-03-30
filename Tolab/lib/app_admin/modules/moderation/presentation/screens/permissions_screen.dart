import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../state/app_state.dart';
import '../../models/moderation_models.dart';
import '../widgets/moderation_helpers.dart';

class ModerationPermissionsScreen extends StatelessWidget {
  const ModerationPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _PermissionsViewModel>(
      converter: (store) => _PermissionsViewModel(
        scopes: store.state.moderationState.permissionScopes,
        roles: store.state.moderationState.roleProfiles,
      ),
      builder: (context, vm) {
        return ListView.separated(
          itemCount: vm.roles.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final role = vm.roles[index];
            return AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role.roleName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${role.memberCount} members  •  ${role.membersPreview.join(', ')}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const StatusBadge('Moderation role'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...vm.scopes.map(
                    (scope) => SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: role.permissions[scope.key] ?? false,
                      title: Text(scope.label),
                      subtitle: Text(scope.description),
                      onChanged: (enabled) => dispatchModerationCommand(
                        context,
                        command: ModerationActionCommand(
                          actionType: ModerationActionType.updatePermission,
                          targetType: 'role',
                          targetIds: [role.id],
                          permissionKey: scope.key,
                          permissionEnabled: enabled,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PermissionsViewModel {
  const _PermissionsViewModel({
    required this.scopes,
    required this.roles,
  });

  final List<ModerationPermissionScope> scopes;
  final List<ModerationRoleProfile> roles;
}
