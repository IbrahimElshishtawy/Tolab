import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../mock/mock_portal_models.dart';
import '../../../models/doctor_assistant_models.dart';
import '../../../modules/auth/state/session_selectors.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../state/section_content_actions.dart';
import '../state/section_content_state.dart';
import 'models/sections_workspace_models.dart';
import 'widgets/sections_workspace_page.dart';

class SectionContentScreen extends StatelessWidget {
  const SectionContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _SectionsScreenVm>(
      onInit: _onLoad,
      converter: _SectionsScreenVm.fromStore,
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) {
          return const SizedBox.shrink();
        }

        final workspaceData = buildSectionsWorkspaceData(
          subjects: vm.subjects,
          notifications: vm.notifications,
          announcements: vm.announcements,
        );

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.sectionContent,
          child: DoctorAssistantPageScaffold(
            title: 'Sections Workspace',
            subtitle:
                'Plan, publish, and monitor section delivery with operational visibility for the doctor and assistant team.',
            breadcrumbs: const ['Workspace', 'Sections'],
            actions: [
              FilledButton.tonalIcon(
                onPressed: vm.reload,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
              ),
            ],
            child: SectionsWorkspacePage(
              sectionState: vm.state,
              workspaceData: workspaceData,
              subjects: vm.subjects,
              onReload: vm.reload,
              onSaveSection: vm.save,
              onPublishSection: vm.publishSection,
            ),
          ),
        );
      },
    );
  }
}

SectionContentState _stateSelector(DoctorAssistantAppState state) =>
    state.sectionContentState;

void _onLoad(Store<DoctorAssistantAppState> store) =>
    store.dispatch(LoadSectionContentAction());

void _onSave(
  Store<DoctorAssistantAppState> store,
  Map<String, dynamic> payload,
) => store.dispatch(SaveSectionContentAction(payload));

class _SectionsScreenVm {
  const _SectionsScreenVm({
    required this.user,
    required this.state,
    required this.subjects,
    required this.notifications,
    required this.announcements,
    required this.reload,
    required this.save,
    required this.publishSection,
  });

  final SessionUser? user;
  final SectionContentState state;
  final List<TeachingSubject> subjects;
  final List<WorkspaceNotificationItem> notifications;
  final List<MockAnnouncementItem> announcements;
  final VoidCallback reload;
  final ValueChanged<Map<String, dynamic>> save;
  final ValueChanged<int> publishSection;

  factory _SectionsScreenVm.fromStore(Store<DoctorAssistantAppState> store) {
    final user = getCurrentUser(store.state);
    final repository = DoctorAssistantMockRepository.instance;
    final safeUser = user ?? repository.userByEmail('assistant@tolab.edu');
    return _SectionsScreenVm(
      user: user,
      state: _stateSelector(store.state),
      subjects: repository.subjectsFor(safeUser),
      notifications: repository.notificationsFor(safeUser),
      announcements: repository.announcementsFor(safeUser),
      reload: () => _onLoad(store),
      save: (payload) => _onSave(store, payload),
      publishSection: (sectionId) {
        repository.publishSection(sectionId);
        _onLoad(store);
      },
    );
  }
}
