import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../core/models/academic_models.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_items.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/state_views.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/admin_actions.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _AdminVm>(
      converter: (store) => _AdminVm.fromStore(store),
      onInit: (store) {
        store.dispatch(LoadAdminOverviewAction());
        store.dispatch(LoadPermissionsAction());
        store.dispatch(LoadDepartmentsAction());
      },
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();

        return AppShell(
          user: user,
          title: 'Admin Control',
          activePath: AppRoutes.admin,
          items: buildNavigationItems(user),
          body: vm.overview == null
              ? const LoadingStateView()
              : ListView(
                  children: [
                    AppCard(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: vm.overview!.entries
                            .map(
                              (entry) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(entry.key),
                                  const SizedBox(height: 6),
                                  Text(
                                    entry.value.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Permission matrix',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: vm.permissions
                                .map((permission) => AppBadge(label: permission))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Departments',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          ...vm.departments.map(
                            (DepartmentModel department) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(department.name),
                              subtitle: Text(department.description ?? ''),
                              trailing: AppBadge(label: department.code),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _AdminVm {
  const _AdminVm({
    required this.user,
    required this.overview,
    required this.permissions,
    required this.departments,
  });

  final SessionUser? user;
  final Map<String, dynamic>? overview;
  final List<String> permissions;
  final List<DepartmentModel> departments;

  factory _AdminVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _AdminVm(
      user: getCurrentUser(store.state),
      overview: store.state.adminState.overview.data,
      permissions: store.state.adminState.permissions.data ?? const [],
      departments: store.state.adminState.departments.data ?? const [],
    );
  }
}
