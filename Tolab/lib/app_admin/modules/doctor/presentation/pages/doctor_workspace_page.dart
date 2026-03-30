import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../academy_panel/models/academy_models.dart';
import '../../../academy_panel/state/academy_actions.dart';
import '../../../academy_panel/state/academy_state.dart';
import '../../../academy_panel/widgets/academy_shell.dart';
import '../../../academy_panel/widgets/role_page_view.dart';
import '../../models/doctor_models.dart';
import '../../state/doctor_actions.dart';
import '../../widgets/doctor_widgets.dart';

class DoctorWorkspacePage extends StatelessWidget {
  const DoctorWorkspacePage({super.key, required this.pageKey});

  final String pageKey;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AcademyAppState, _DoctorViewModel>(
      converter: (store) {
        final state = store.state.doctorState;
        return _DoctorViewModel(
          user: store.state.session.user!,
          status: state.status,
          errorMessage: state.errorMessage,
          unreadCount: state.unreadCount,
          page:
              state.pageFor(pageKey) ??
              buildDoctorPageData(pageKey, notifications: state.notifications),
        );
      },
      builder: (context, vm) {
        final store = StoreProvider.of<AcademyAppState>(context);
        return AcademyShell(
          role: AcademyRole.doctor,
          currentPageKey: pageKey,
          navigationItems: doctorNavigationItems,
          user: vm.user,
          unreadCount: vm.unreadCount,
          onLogout: () => store.dispatch(AcademyLogoutRequestedAction()),
          onToggleTheme: () => store.dispatch(AcademyThemeModeToggledAction()),
          child: RolePageView(
            header: const DoctorWorkspaceBanner(),
            page: vm.page,
            loading: vm.status.isLoading,
            errorMessage: vm.errorMessage,
            onRefresh: () =>
                store.dispatch(DoctorLoadPageAction(pageKey, force: true)),
            onPrimaryAction: () async {
              final table = _firstTable(vm.page);
              if (table == null) {
                store.dispatch(
                  AcademyToastQueuedAction(
                    AcademyToast(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      title: 'Doctor Workspace',
                      message:
                          'Use the upload panel or schedule section below to continue.',
                      role: AcademyRole.doctor,
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
                DoctorCrudRequestedAction(pageKey: pageKey, payload: result),
              );
            },
            onEditRow: (row) async {
              final table = _firstTable(vm.page);
              if (table == null) return;
              final result = await showRecordEditorDialog(
                context,
                title: 'Update ${vm.page.title}',
                columns: table.columns,
                initial: row,
              );
              if (result == null) return;
              store.dispatch(
                DoctorCrudRequestedAction(
                  pageKey: pageKey,
                  entityId: row['id']?.toString(),
                  payload: result,
                ),
              );
            },
            onDeleteRow: (_) {},
            onUploadFiles: (files) {
              store.dispatch(
                DoctorUploadRequestedAction(pageKey: pageKey, files: files),
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
}

class _DoctorViewModel {
  const _DoctorViewModel({
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
