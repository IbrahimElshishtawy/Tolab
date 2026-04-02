import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_items.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/responsive_data_table.dart';
import '../../../core/widgets/state_views.dart';
import '../../../state/app_state.dart';
import '../../admin/state/admin_actions.dart';
import '../../auth/state/session_selectors.dart';
import '../state/staff_actions.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _StaffVm>(
      converter: (store) => _StaffVm.fromStore(store),
      onInit: (store) => store.dispatch(LoadStaffAction()),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();

        return AppShell(
          user: user,
          title: 'Staff Management',
          activePath: AppRoutes.staff,
          items: buildNavigationItems(user),
          body: vm.items == null
              ? const LoadingStateView()
              : ResponsiveDataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Department')),
                    DataColumn(label: Text('Assignments')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: vm.items!
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(Text(item.user.fullName)),
                            DataCell(Text(item.departmentName)),
                            DataCell(Text(item.assignmentSummary)),
                            DataCell(
                              Switch(
                                value: item.user.isActive,
                                onChanged: (value) =>
                                    vm.toggleActivation(item.user.id, value),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                  mobileBuilder: () => vm.items!
                      .map(
                        (item) => Card(
                          child: ListTile(
                            title: Text(item.user.fullName),
                            subtitle: Text(item.assignmentSummary),
                            trailing: AppBadge(
                              label: item.user.isActive ? 'Active' : 'Inactive',
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}

class _StaffVm {
  const _StaffVm({
    required this.user,
    required this.items,
    required this.toggleActivation,
  });

  final SessionUser? user;
  final List<StaffMemberModel>? items;
  final void Function(int userId, bool isActive) toggleActivation;

  factory _StaffVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _StaffVm(
      user: getCurrentUser(store.state),
      items: store.state.staffState.data,
      toggleActivation: (userId, isActive) {
        store.dispatch(
          ToggleStaffActivationAction(userId: userId, isActive: isActive),
        );
      },
    );
  }
}
