import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../academy_panel/models/academy_models.dart';
import '../../../academy_panel/state/academy_actions.dart';
import '../../../academy_panel/state/academy_state.dart';
import '../../../academy_panel/widgets/academy_shell.dart';
import '../../../academy_panel/widgets/role_page_view.dart';
import '../../models/admin_models.dart';
import '../../state/admin_actions.dart';
import '../../widgets/admin_widgets.dart';

class AdminWorkspacePage extends StatelessWidget {
  const AdminWorkspacePage({super.key, required this.pageKey});

  final String pageKey;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AcademyAppState, _AdminViewModel>(
      converter: (store) {
        final state = store.state.adminState;
        return _AdminViewModel(
          user: store.state.session.user!,
          status: state.status,
          errorMessage: state.errorMessage,
          unreadCount: state.unreadCount,
          page:
              state.pageFor(pageKey) ??
              buildAdminPageData(pageKey, notifications: state.notifications),
        );
      },
      builder: (context, vm) {
        final store = StoreProvider.of<AcademyAppState>(context);
        return AcademyShell(
          role: AcademyRole.admin,
          currentPageKey: pageKey,
          navigationItems: adminNavigationItems,
          user: vm.user,
          unreadCount: vm.unreadCount,
          onLogout: () => store.dispatch(AcademyLogoutRequestedAction()),
          onToggleTheme: () => store.dispatch(AcademyThemeModeToggledAction()),
          child: RolePageView(
            header: const AdminWorkspaceBanner(),
            page: vm.page,
            loading: vm.status.isLoading,
            errorMessage: vm.errorMessage,
            onRefresh: () =>
                store.dispatch(AdminLoadPageAction(pageKey, force: true)),
            onPrimaryAction: () async {
              final table = _firstTable(vm.page);
              if (table == null) {
                store.dispatch(
                  AcademyToastQueuedAction(
                    AcademyToast(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      title: 'Admin Action',
                      message:
                          'Use the page-specific controls below to complete this action.',
                      role: AcademyRole.admin,
                    ),
                  ),
                );
                return;
              }
              final result = await showRecordEditorDialog(
                context,
                title: vm.page.primaryActionLabel,
                columns: table.columns,
              );
              if (result == null) return;
              store.dispatch(
                AdminCrudRequestedAction(pageKey: pageKey, payload: result),
              );
            },
            onEditRow: (row) async {
              final table = _firstTable(vm.page);
              if (table == null) return;
              final result = await showRecordEditorDialog(
                context,
                title: 'Edit ${vm.page.title}',
                columns: table.columns,
                initial: row,
              );
              if (result == null) return;
              store.dispatch(
                AdminCrudRequestedAction(
                  pageKey: pageKey,
                  entityId: _entityId(row),
                  payload: result,
                ),
              );
            },
            onDeleteRow: (row) {
              store.dispatch(
                AdminCrudRequestedAction(
                  pageKey: pageKey,
                  entityId: _entityId(row),
                  payload: row,
                  delete: true,
                ),
              );
            },
            onUploadFiles: (files) {
              store.dispatch(
                AdminUploadRequestedAction(pageKey: pageKey, files: files),
              );
            },
          ),
        );
      },
    );
  }

  PanelTableData? _firstTable(RolePageData page) {
    for (final section in page.sections) {
      if (section.type == PageSectionType.table && section.table != null) {
        return section.table;
      }
    }
    return null;
  }

  String _entityId(JsonMap row) {
    return row['id']?.toString() ??
        row['code']?.toString() ??
        row['name']?.toString() ??
        row['student']?.toString() ??
        'record';
  }
}

class _AdminViewModel {
  const _AdminViewModel({
    required this.user,
    required this.page,
    required this.status,
    required this.unreadCount,
    this.errorMessage,
  });

  final AcademyUser user;
  final RolePageData page;
  final PanelLoadStatus status;
  final int unreadCount;
  final String? errorMessage;
}
