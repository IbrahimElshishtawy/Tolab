import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../shared/forms/app_text_field.dart';
import '../../../../shared/widgets/async_state_view.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../state/app_state.dart';
import '../../models/permission_model.dart';
import '../../models/role_model.dart';
import '../../state/roles_actions.dart';
import '../../state/roles_selectors.dart';
import '../../state/roles_state.dart';
import '../widgets/role_card.dart';
import 'permissions_matrix_screen.dart';
import 'role_detail_screen.dart';

class RolesListScreen extends StatefulWidget {
  const RolesListScreen({super.key});

  @override
  State<RolesListScreen> createState() => _RolesListScreenState();
}

class _RolesListScreenState extends State<RolesListScreen> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _RolesPageViewModel>(
      distinct: true,
      onInit: (store) {
        if (store.state.rolesState.status == LoadStatus.initial) {
          store.dispatch(const RolesDashboardRequestedAction());
        }
      },
      onDidChange: (previous, current) {
        if (!mounted) return;
        if (current.feedbackMessage != null &&
            current.feedbackMessage != previous?.feedbackMessage) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(current.feedbackMessage!)));
        }
      },
      converter: _RolesPageViewModel.fromStore,
      builder: (context, vm) {
        final isDesktop = AppBreakpoints.isDesktop(context);
        final isMobile = AppBreakpoints.isMobile(context);

        return LayoutBuilder(
          builder: (context, constraints) {
            final workspaceHeight =
                (constraints.maxHeight * (isMobile ? 0.78 : 0.62))
                    .clamp(420.0, 840.0)
                    .toDouble();

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      title: 'Roles & Permissions',
                      subtitle:
                          'Manage university security with role CRUD, permission governance, membership assignment, and a responsive access matrix.',
                      breadcrumbs: const ['Admin', 'Security', 'Roles'],
                      actions: [
                        PremiumButton(
                          label: 'New role',
                          icon: Icons.add_moderator_rounded,
                          onPressed: () => _openRoleDialog(context, vm),
                        ),
                        PremiumButton(
                          label: 'New permission',
                          icon: Icons.shield_moon_rounded,
                          isSecondary: true,
                          onPressed: () => _openPermissionDialog(context, vm),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _OverviewMetricsStrip(vm: vm),
                    const SizedBox(height: AppSpacing.md),
                    FilterBar(
                      searchHint:
                          'Search roles, permissions, users, or modules',
                      onSearchChanged: (value) => vm.updateFilters(
                        vm.filters.copyWith(searchQuery: value),
                      ),
                      leading: [
                        _ModuleMenu(
                          modules: vm.modules,
                          selectedModule: vm.filters.moduleFilter,
                          onSelected: (module) {
                            if (module == null) {
                              vm.updateFilters(
                                vm.filters.copyWith(clearModuleFilter: true),
                              );
                            } else {
                              vm.updateFilters(
                                vm.filters.copyWith(moduleFilter: module),
                              );
                            }
                          },
                        ),
                        _SortMenu(
                          value: vm.filters.sortOption,
                          onSelected: (value) => vm.updateFilters(
                            vm.filters.copyWith(sortOption: value),
                          ),
                        ),
                      ],
                      trailing: [
                        FilterChip(
                          selected: vm.filters.showSystemRoles,
                          label: const Text('System roles'),
                          onSelected: (value) => vm.updateFilters(
                            vm.filters.copyWith(showSystemRoles: value),
                          ),
                        ),
                        _ViewToggle(value: vm.view, onChanged: vm.changeView),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (vm.isFallback)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          backgroundColor: AppColors.warningSoft.withValues(
                            alpha: 0.55,
                          ),
                          borderColor: AppColors.warning.withValues(alpha: 0.2),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Live security data is unavailable, so the module is working from cached or bundled fallback records.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(
                      height: workspaceHeight,
                      child: AsyncStateView(
                        status: vm.status,
                        errorMessage: vm.errorMessage,
                        onRetry: vm.reload,
                        isEmpty:
                            vm.status == LoadStatus.success &&
                            vm.roles.isEmpty &&
                            vm.permissions.isEmpty,
                        emptyTitle: 'No roles or permissions found',
                        emptySubtitle:
                            'Create a role or connect the Laravel API to begin managing access.',
                        child: AnimatedSwitcher(
                          duration: AppMotion.medium,
                          switchInCurve: AppMotion.entrance,
                          switchOutCurve: AppMotion.emphasized,
                          child: vm.view == RolesDashboardView.matrix
                              ? PermissionsMatrixScreen(
                                  key: const ValueKey('matrix-view'),
                                  roles: vm.roles,
                                  permissions: vm.filteredPermissions,
                                  pendingCellKeys: vm.pendingCellKeys,
                                  onPermissionToggle:
                                      (role, permission, value) {
                                        vm.togglePermission(
                                          role.id,
                                          permission.id,
                                          value,
                                        );
                                      },
                                )
                              : _RolesWorkspace(
                                  key: const ValueKey('roles-view'),
                                  isDesktop: isDesktop,
                                  isMobile: isMobile,
                                  roles: vm.roles,
                                  selectedRole: vm.selectedRole,
                                  filteredPermissions: vm.filteredPermissions,
                                  permissionCount: vm.permissions.length,
                                  availableUsers: vm.availableUsers,
                                  pendingPermissionIds:
                                      vm.pendingPermissionIdsForSelectedRole,
                                  isUsersBusy: vm.isUsersBusy,
                                  onSelectRole: vm.selectRole,
                                  onCreateRole: () =>
                                      _openRoleDialog(context, vm),
                                  onEditRole: vm.selectedRole == null
                                      ? null
                                      : () => _openRoleDialog(
                                          context,
                                          vm,
                                          role: vm.selectedRole,
                                        ),
                                  onDeleteRole: vm.selectedRole == null
                                      ? null
                                      : () => _deleteRole(
                                          context,
                                          vm,
                                          vm.selectedRole!,
                                        ),
                                  onAssignUsers: vm.selectedRole == null
                                      ? null
                                      : () => _openAssignUsersDialog(
                                          context,
                                          vm,
                                          vm.selectedRole!,
                                        ),
                                  onCreatePermission: () =>
                                      _openPermissionDialog(context, vm),
                                  onEditPermission: (permission) =>
                                      _openPermissionDialog(
                                        context,
                                        vm,
                                        permission: permission,
                                      ),
                                  onDeletePermission: (permission) =>
                                      _deletePermission(
                                        context,
                                        vm,
                                        permission,
                                      ),
                                  onTogglePermission: (permission, value) {
                                    final role = vm.selectedRole;
                                    if (role == null) return;
                                    vm.togglePermission(
                                      role.id,
                                      permission.id,
                                      value,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openRoleDialog(
    BuildContext context,
    _RolesPageViewModel vm, {
    RoleModel? role,
  }) async {
    final result = await _showAdaptiveDialog<RoleUpsertPayload>(
      context,
      child: _RoleFormDialog(initialRole: role),
    );
    if (!mounted || result == null) return;
    if (role == null) {
      vm.createRole(result);
    } else {
      vm.updateRole(role.id, result);
    }
  }

  Future<void> _openPermissionDialog(
    BuildContext context,
    _RolesPageViewModel vm, {
    PermissionModel? permission,
  }) async {
    final result = await _showAdaptiveDialog<PermissionUpsertPayload>(
      context,
      child: _PermissionFormDialog(initialPermission: permission),
    );
    if (!mounted || result == null) return;
    if (permission == null) {
      vm.createPermission(result);
    } else {
      vm.updatePermission(permission.id, result);
    }
  }

  Future<void> _openAssignUsersDialog(
    BuildContext context,
    _RolesPageViewModel vm,
    RoleModel role,
  ) async {
    final result = await _showAdaptiveDialog<List<String>>(
      context,
      child: _AssignUsersDialog(role: role, users: vm.availableUsers),
    );
    if (!mounted || result == null) return;
    vm.assignUsers(role.id, result);
  }

  Future<void> _deleteRole(
    BuildContext context,
    _RolesPageViewModel vm,
    RoleModel role,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete ${role.name}?',
      message:
          'This removes the role and its assignments. Existing users will lose that access immediately.',
    );
    if (!confirmed) return;
    vm.deleteRole(role.id);
  }

  Future<void> _deletePermission(
    BuildContext context,
    _RolesPageViewModel vm,
    PermissionModel permission,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete ${permission.name}?',
      message:
          'This permission will be removed from every role that currently grants it.',
    );
    if (!confirmed) return;
    vm.deletePermission(permission.id);
  }
}

class _RolesWorkspace extends StatefulWidget {
  const _RolesWorkspace({
    super.key,
    required this.isDesktop,
    required this.isMobile,
    required this.roles,
    required this.selectedRole,
    required this.filteredPermissions,
    required this.permissionCount,
    required this.availableUsers,
    required this.pendingPermissionIds,
    required this.isUsersBusy,
    required this.onSelectRole,
    required this.onCreateRole,
    required this.onEditRole,
    required this.onDeleteRole,
    required this.onAssignUsers,
    required this.onCreatePermission,
    required this.onEditPermission,
    required this.onDeletePermission,
    required this.onTogglePermission,
  });

  final bool isDesktop;
  final bool isMobile;
  final List<RoleModel> roles;
  final RoleModel? selectedRole;
  final List<PermissionModel> filteredPermissions;
  final int permissionCount;
  final List<RoleUserAssignment> availableUsers;
  final Set<String> pendingPermissionIds;
  final bool isUsersBusy;
  final ValueChanged<String> onSelectRole;
  final VoidCallback onCreateRole;
  final VoidCallback? onEditRole;
  final VoidCallback? onDeleteRole;
  final VoidCallback? onAssignUsers;
  final VoidCallback onCreatePermission;
  final ValueChanged<PermissionModel> onEditPermission;
  final ValueChanged<PermissionModel> onDeletePermission;
  final void Function(PermissionModel permission, bool value)
  onTogglePermission;

  @override
  State<_RolesWorkspace> createState() => _RolesWorkspaceState();
}

class _RolesWorkspaceState extends State<_RolesWorkspace> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rolesList = _RolesListPane(
      roles: widget.roles,
      selectedRoleId: widget.selectedRole?.id,
      permissionCount: widget.permissionCount,
      onCreateRole: widget.onCreateRole,
      onSelectRole: widget.onSelectRole,
    );
    final detail = RoleDetailScreen(
      role: widget.selectedRole,
      permissions: widget.filteredPermissions,
      availableUsers: widget.availableUsers,
      pendingPermissionIds: widget.pendingPermissionIds,
      isUsersBusy: widget.isUsersBusy,
      onEditRole: widget.onEditRole ?? () {},
      onDeleteRole: widget.onDeleteRole ?? () {},
      onAssignUsers: widget.onAssignUsers ?? () {},
      onCreatePermission: widget.onCreatePermission,
      onEditPermission: widget.onEditPermission,
      onDeletePermission: widget.onDeletePermission,
      onTogglePermission: widget.onTogglePermission,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackContent =
            widget.isMobile || !widget.isDesktop || constraints.maxWidth < 1180;
        final content = stackContent
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  rolesList,
                  const SizedBox(height: AppSpacing.lg),
                  detail,
                ],
              )
            : SizedBox(
                width: constraints.maxWidth,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 360, child: rolesList),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: detail),
                  ],
                ),
              );

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: content,
          ),
        );
      },
    );
  }
}

class _RolesListPane extends StatelessWidget {
  const _RolesListPane({
    required this.roles,
    required this.selectedRoleId,
    required this.permissionCount,
    required this.onCreateRole,
    required this.onSelectRole,
  });

  final List<RoleModel> roles;
  final String? selectedRoleId;
  final int permissionCount;
  final VoidCallback onCreateRole;
  final ValueChanged<String> onSelectRole;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;
              return isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Roles',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Compact role cards with member and coverage signals.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton.icon(
                          onPressed: onCreateRole,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Create'),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Roles',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Compact role cards with member and coverage signals.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: onCreateRole,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Create'),
                        ),
                      ],
                    );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          if (roles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'No roles match the current filters.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            AnimationLimiter(
              child: Column(
                children: [
                  for (var index = 0; index < roles.length; index++) ...[
                    AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 360),
                      child: SlideAnimation(
                        verticalOffset: 20,
                        child: FadeInAnimation(
                          child: RoleCard(
                            role: roles[index],
                            permissionCount: roles[index].permissionIds.length,
                            permissionCoverage: permissionCoverageForRole(
                              roles[index],
                              permissionCount,
                            ),
                            selected: roles[index].id == selectedRoleId,
                            onTap: () => onSelectRole(roles[index].id),
                          ),
                        ),
                      ),
                    ),
                    if (index != roles.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OverviewMetricsStrip extends StatelessWidget {
  const _OverviewMetricsStrip({required this.vm});

  final _RolesPageViewModel vm;

  @override
  Widget build(BuildContext context) {
    final metrics = vm.metrics;
    final items = [
      _SummaryMetric(
        title: 'Roles',
        value: '${metrics.totalRoles}',
        caption: '${metrics.systemRoles} protected system roles',
        color: AppColors.primary,
        icon: Icons.admin_panel_settings_rounded,
      ),
      _SummaryMetric(
        title: 'Permissions',
        value: '${metrics.totalPermissions}',
        caption:
            '${metrics.averagePermissionsPerRole.toStringAsFixed(1)} average per role',
        color: AppColors.info,
        icon: Icons.verified_user_rounded,
      ),
      _SummaryMetric(
        title: 'Users Covered',
        value: '${metrics.coveredUsers}',
        caption: 'Members connected to at least one security role',
        color: AppColors.secondary,
        icon: Icons.people_alt_rounded,
      ),
      _SummaryMetric(
        title: 'Last Sync',
        value: vm.lastSyncedLabel,
        caption: 'Latest dashboard refresh timestamp',
        color: AppColors.warning,
        icon: Icons.sync_rounded,
      ),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final item in items)
          SizedBox(
            width: 260,
            child: AppCard(
              interactive: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        AppConstants.mediumRadius,
                      ),
                    ),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.value,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.caption,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryMetric {
  const _SummaryMetric({
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final Color color;
  final IconData icon;
}

class _ModuleMenu extends StatelessWidget {
  const _ModuleMenu({
    required this.modules,
    required this.selectedModule,
    required this.onSelected,
  });

  final List<String> modules;
  final String? selectedModule;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem<String?>(value: null, child: Text('All modules')),
        for (final module in modules)
          PopupMenuItem<String?>(value: module, child: Text(module)),
      ],
      child: _ToolbarChip(
        icon: Icons.category_rounded,
        label: selectedModule ?? 'All modules',
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.value, required this.onSelected});

  final RolesSortOption value;
  final ValueChanged<RolesSortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<RolesSortOption>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final option in RolesSortOption.values)
          PopupMenuItem<RolesSortOption>(
            value: option,
            child: Text(option.label),
          ),
      ],
      child: _ToolbarChip(icon: Icons.sort_rounded, label: value.label),
    );
  }
}

class _ToolbarChip extends StatelessWidget {
  const _ToolbarChip({required this.icon, required this.label});

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
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.value, required this.onChanged});

  final RolesDashboardView value;
  final ValueChanged<RolesDashboardView> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<RolesDashboardView>(
      selected: <RolesDashboardView>{value},
      showSelectedIcon: false,
      segments: const [
        ButtonSegment<RolesDashboardView>(
          value: RolesDashboardView.roles,
          icon: Icon(Icons.view_list_rounded),
          label: Text('Roles'),
        ),
        ButtonSegment<RolesDashboardView>(
          value: RolesDashboardView.matrix,
          icon: Icon(Icons.grid_on_rounded),
          label: Text('Matrix'),
        ),
      ],
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
    );
  }
}

class _RoleFormDialog extends StatefulWidget {
  const _RoleFormDialog({this.initialRole});

  final RoleModel? initialRole;

  @override
  State<_RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends State<_RoleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _descriptionController;
  late String _colorHex;

  static const List<String> _palette = [
    '2563EB',
    '0EA5E9',
    '16A34A',
    'F59E0B',
    'EF4444',
    '6366F1',
  ];

  @override
  void initState() {
    super.initState();
    final role = widget.initialRole;
    _nameController = TextEditingController(text: role?.name ?? '');
    _slugController = TextEditingController(text: role?.slug ?? '');
    _descriptionController = TextEditingController(
      text: role?.description ?? '',
    );
    _colorHex = role?.colorHex ?? _palette.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialRole != null;
    return _DialogFrame(
      title: isEdit ? 'Edit role' : 'Create role',
      subtitle: 'Define the role profile, tone, and API-ready metadata.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Role name',
              hint: 'Registrar Lead',
              validator: _requiredValidator,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _slugController,
              label: 'Slug',
              hint: 'registrar-lead',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _descriptionController,
              label: 'Description',
              hint:
                  'Describe what this role can own across the university workspace.',
              maxLines: 4,
              validator: _requiredValidator,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Accent color', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final color in _palette)
                  InkWell(
                    borderRadius: BorderRadius.circular(
                      AppConstants.pillRadius,
                    ),
                    onTap: () => setState(() => _colorHex = color),
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      curve: AppMotion.emphasized,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _colorHex == color
                              ? _colorFromHex(color)
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.pillRadius,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: _colorFromHex(color),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Align(
              alignment: Alignment.centerRight,
              child: PremiumButton(
                label: isEdit ? 'Save role' : 'Create role',
                icon: isEdit ? Icons.save_rounded : Icons.add_rounded,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      RoleUpsertPayload(
        name: _nameController.text.trim(),
        slug: _slugController.text.trim().isEmpty
            ? null
            : _slugController.text.trim(),
        description: _descriptionController.text.trim(),
        colorHex: _colorHex,
        isSystem: widget.initialRole?.isSystem ?? false,
      ),
    );
  }
}

class _PermissionFormDialog extends StatefulWidget {
  const _PermissionFormDialog({this.initialPermission});

  final PermissionModel? initialPermission;

  @override
  State<_PermissionFormDialog> createState() => _PermissionFormDialogState();
}

class _PermissionFormDialogState extends State<_PermissionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late final TextEditingController _moduleController;
  late final TextEditingController _descriptionController;
  late PermissionActionKind _action;

  @override
  void initState() {
    super.initState();
    final permission = widget.initialPermission;
    _nameController = TextEditingController(text: permission?.name ?? '');
    _keyController = TextEditingController(text: permission?.key ?? '');
    _moduleController = TextEditingController(text: permission?.module ?? '');
    _descriptionController = TextEditingController(
      text: permission?.description ?? '',
    );
    _action = permission?.action ?? PermissionActionKind.manage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _moduleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialPermission != null;
    return _DialogFrame(
      title: isEdit ? 'Edit permission' : 'Create permission',
      subtitle:
          'Add a permission that maps cleanly to your Laravel authorization layer.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Permission name',
              hint: 'Approve enrollments',
              validator: _requiredValidator,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _keyController,
              label: 'Permission key',
              hint: 'enrollments_approve',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _moduleController,
              label: 'Module',
              hint: 'Enrollments',
              validator: _requiredValidator,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<PermissionActionKind>(
              initialValue: _action,
              items: [
                for (final action in PermissionActionKind.values.where(
                  (entry) => entry != PermissionActionKind.unknown,
                ))
                  DropdownMenuItem<PermissionActionKind>(
                    value: action,
                    child: Text(action.label),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _action = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Action'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe the exact access this permission should grant.',
              maxLines: 4,
              validator: _requiredValidator,
            ),
            const SizedBox(height: AppSpacing.xl),
            Align(
              alignment: Alignment.centerRight,
              child: PremiumButton(
                label: isEdit ? 'Save permission' : 'Create permission',
                icon: isEdit ? Icons.save_rounded : Icons.add_rounded,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      PermissionUpsertPayload(
        name: _nameController.text.trim(),
        key: _keyController.text.trim().isEmpty
            ? null
            : _keyController.text.trim(),
        module: _moduleController.text.trim(),
        action: _action,
        description: _descriptionController.text.trim(),
        isCore: widget.initialPermission?.isCore ?? false,
      ),
    );
  }
}

class _AssignUsersDialog extends StatefulWidget {
  const _AssignUsersDialog({required this.role, required this.users});

  final RoleModel role;
  final List<RoleUserAssignment> users;

  @override
  State<_AssignUsersDialog> createState() => _AssignUsersDialogState();
}

class _AssignUsersDialogState extends State<_AssignUsersDialog> {
  late final Set<String> _selectedUserIds;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedUserIds = widget.role.userIds.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = widget.users
        .where((user) {
          final query = _query.trim().toLowerCase();
          if (query.isEmpty) return true;
          final haystack = '${user.name} ${user.email} ${user.department}'
              .toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);

    return _DialogFrame(
      title: 'Assign users',
      subtitle:
          'Select the people who should inherit ${widget.role.name} access.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Search users',
            hint: 'Search by name, email, or department',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 360,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filteredUsers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return CheckboxListTile(
                  value: _selectedUserIds.contains(user.id),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedUserIds.add(user.id);
                      } else {
                        _selectedUserIds.remove(user.id);
                      }
                    });
                  },
                  title: Text(user.name),
                  subtitle: Text('${user.email} - ${user.department}'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerRight,
            child: PremiumButton(
              label: 'Apply users',
              icon: Icons.check_rounded,
              onPressed: () => Navigator.of(
                context,
              ).pop(_selectedUserIds.toList(growable: false)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogFrame extends StatelessWidget {
  const _DialogFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> _showAdaptiveDialog<T>(
  BuildContext context, {
  required Widget child,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierLabel: 'roles-dialog',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    pageBuilder: (dialogContext, animation, secondaryAnimation) => child,
    transitionBuilder: (context, animation, secondaryAnimation, dialogChild) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.entrance,
        reverseCurve: AppMotion.emphasized,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: dialogChild,
        ),
      );
    },
  );
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required.';
  }
  return null;
}

Color _colorFromHex(String hex) {
  final value = hex.replaceAll('#', '');
  final normalized = value.length == 6 ? 'FF$value' : value;
  return Color(int.tryParse(normalized, radix: 16) ?? 0xFF2563EB);
}

class _RolesPageViewModel {
  _RolesPageViewModel({
    required this.status,
    required this.roles,
    required this.permissions,
    required this.filteredPermissions,
    required this.selectedRole,
    required this.availableUsers,
    required this.filters,
    required this.view,
    required this.metrics,
    required this.modules,
    required this.pendingCellKeys,
    required this.pendingPermissionIdsForSelectedRole,
    required this.isUsersBusy,
    required this.isFallback,
    required this.errorMessage,
    required this.feedbackMessage,
    required this.lastSyncedLabel,
    required this.reload,
    required this.updateFilters,
    required this.changeView,
    required this.selectRole,
    required this.createRole,
    required this.updateRole,
    required this.deleteRole,
    required this.createPermission,
    required this.updatePermission,
    required this.deletePermission,
    required this.togglePermission,
    required this.assignUsers,
    required List<String> roleSignatures,
    required List<String> permissionSignatures,
    required List<String> userSignatures,
  }) : _roleSignatures = roleSignatures,
       _permissionSignatures = permissionSignatures,
       _userSignatures = userSignatures;

  static _RolesPageViewModel fromStore(Store<AppState> store) {
    final rolesState = rolesStateOf(store.state);
    final roles = selectFilteredRoles(rolesState);
    final permissions = selectAllPermissions(rolesState);
    final filteredPermissions = selectFilteredPermissions(rolesState);
    final selectedRole = selectSelectedRole(rolesState);
    final availableUsers = selectAvailableUsersForRole(
      rolesState,
      selectedRole?.id,
    );
    final pendingPermissionIds = {
      for (final permission in filteredPermissions)
        if (selectedRole != null &&
            isPermissionBusy(rolesState, selectedRole.id, permission.id))
          permission.id,
    };

    return _RolesPageViewModel(
      status: rolesState.status,
      roles: roles,
      permissions: permissions,
      filteredPermissions: filteredPermissions,
      selectedRole: selectedRole,
      availableUsers: availableUsers,
      filters: rolesState.filters,
      view: rolesState.view,
      metrics: selectRolesOverviewMetrics(rolesState),
      modules: selectPermissionModules(rolesState),
      pendingCellKeys: rolesState.pendingPermissionKeys,
      pendingPermissionIdsForSelectedRole: pendingPermissionIds,
      isUsersBusy:
          selectedRole != null &&
          isUsersAssignmentBusy(rolesState, selectedRole.id),
      isFallback: rolesState.isUsingFallbackData,
      errorMessage: rolesState.errorMessage,
      feedbackMessage: rolesState.feedbackMessage,
      lastSyncedLabel: rolesState.lastSyncedAt == null
          ? 'Pending'
          : DateFormat(
              'dd MMM, HH:mm',
            ).format(rolesState.lastSyncedAt!.toLocal()),
      reload: () => store.dispatch(const RolesDashboardRequestedAction()),
      updateFilters: (filters) =>
          store.dispatch(RolesFiltersChangedAction(filters)),
      changeView: (view) =>
          store.dispatch(RolesDashboardViewChangedAction(view)),
      selectRole: (roleId) => store.dispatch(RoleSelectedAction(roleId)),
      createRole: (payload) =>
          store.dispatch(CreateRoleRequestedAction(payload: payload)),
      updateRole: (roleId, payload) => store.dispatch(
        UpdateRoleRequestedAction(roleId: roleId, payload: payload),
      ),
      deleteRole: (roleId) =>
          store.dispatch(DeleteRoleRequestedAction(roleId: roleId)),
      createPermission: (payload) =>
          store.dispatch(CreatePermissionRequestedAction(payload: payload)),
      updatePermission: (permissionId, payload) => store.dispatch(
        UpdatePermissionRequestedAction(
          permissionId: permissionId,
          payload: payload,
        ),
      ),
      deletePermission: (permissionId) => store.dispatch(
        DeletePermissionRequestedAction(permissionId: permissionId),
      ),
      togglePermission: (roleId, permissionId, value) => store.dispatch(
        ToggleRolePermissionRequestedAction(
          roleId: roleId,
          permissionId: permissionId,
          nextValue: value,
        ),
      ),
      assignUsers: (roleId, userIds) => store.dispatch(
        AssignUsersRequestedAction(roleId: roleId, userIds: userIds),
      ),
      roleSignatures: roles
          .map(
            (role) =>
                '${role.id}:${role.updatedAt.millisecondsSinceEpoch}:${role.permissionIds.length}:${role.membersCount}',
          )
          .toList(growable: false),
      permissionSignatures: filteredPermissions
          .map(
            (permission) =>
                '${permission.id}:${permission.updatedAt.millisecondsSinceEpoch}:${permission.roleIds.length}',
          )
          .toList(growable: false),
      userSignatures: availableUsers
          .map((user) => '${user.id}:${user.name}:${user.department}')
          .toList(growable: false),
    );
  }

  final LoadStatus status;
  final List<RoleModel> roles;
  final List<PermissionModel> permissions;
  final List<PermissionModel> filteredPermissions;
  final RoleModel? selectedRole;
  final List<RoleUserAssignment> availableUsers;
  final RolesFilters filters;
  final RolesDashboardView view;
  final RolesOverviewMetrics metrics;
  final List<String> modules;
  final Set<String> pendingCellKeys;
  final Set<String> pendingPermissionIdsForSelectedRole;
  final bool isUsersBusy;
  final bool isFallback;
  final String? errorMessage;
  final String? feedbackMessage;
  final String lastSyncedLabel;
  final VoidCallback reload;
  final ValueChanged<RolesFilters> updateFilters;
  final ValueChanged<RolesDashboardView> changeView;
  final ValueChanged<String> selectRole;
  final ValueChanged<RoleUpsertPayload> createRole;
  final void Function(String roleId, RoleUpsertPayload payload) updateRole;
  final ValueChanged<String> deleteRole;
  final ValueChanged<PermissionUpsertPayload> createPermission;
  final void Function(String permissionId, PermissionUpsertPayload payload)
  updatePermission;
  final ValueChanged<String> deletePermission;
  final void Function(String roleId, String permissionId, bool value)
  togglePermission;
  final void Function(String roleId, List<String> userIds) assignUsers;
  final List<String> _roleSignatures;
  final List<String> _permissionSignatures;
  final List<String> _userSignatures;

  static const _listEquality = ListEquality<String>();
  static const _setEquality = SetEquality<String>();

  @override
  bool operator ==(Object other) {
    return other is _RolesPageViewModel &&
        other.status == status &&
        other.view == view &&
        other.filters.searchQuery == filters.searchQuery &&
        other.filters.moduleFilter == filters.moduleFilter &&
        other.filters.sortOption == filters.sortOption &&
        other.filters.showSystemRoles == filters.showSystemRoles &&
        other.selectedRole?.id == selectedRole?.id &&
        other.isUsersBusy == isUsersBusy &&
        other.isFallback == isFallback &&
        other.errorMessage == errorMessage &&
        other.feedbackMessage == feedbackMessage &&
        other.lastSyncedLabel == lastSyncedLabel &&
        _listEquality.equals(other._roleSignatures, _roleSignatures) &&
        _listEquality.equals(
          other._permissionSignatures,
          _permissionSignatures,
        ) &&
        _listEquality.equals(other._userSignatures, _userSignatures) &&
        _listEquality.equals(other.modules, modules) &&
        _setEquality.equals(other.pendingCellKeys, pendingCellKeys) &&
        _setEquality.equals(
          other.pendingPermissionIdsForSelectedRole,
          pendingPermissionIdsForSelectedRole,
        );
  }

  @override
  int get hashCode => Object.hash(
    status,
    view,
    filters.searchQuery,
    filters.moduleFilter,
    filters.sortOption,
    filters.showSystemRoles,
    selectedRole?.id,
    isUsersBusy,
    isFallback,
    errorMessage,
    feedbackMessage,
    lastSyncedLabel,
    Object.hashAll(_roleSignatures),
    Object.hashAll(_permissionSignatures),
    Object.hashAll(_userSignatures),
    Object.hashAll(modules),
    Object.hashAll(pendingCellKeys.toList()..sort()),
    Object.hashAll(pendingPermissionIdsForSelectedRole.toList()..sort()),
  );
}
