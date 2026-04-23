import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../core/models/content_models.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../mock/mock_portal_models.dart';
import '../../../models/doctor_assistant_models.dart';
import '../../../modules/auth/state/session_selectors.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../state/app_state.dart';
import '../state/tasks_actions.dart';
import '../state/tasks_state.dart';
import 'models/tasks_workspace_models.dart';
import 'widgets/tasks_workspace_page.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _TasksScreenVm>(
      onInit: _onLoad,
      converter: _TasksScreenVm.fromStore,
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) {
          return const SizedBox.shrink();
        }

        final workspaceData = buildTasksWorkspaceData(
          tasks: vm.state.data ?? vm.tasks,
          subjects: vm.subjects,
          results: vm.results,
          announcements: vm.announcements,
          students: vm.students,
          groupPosts: vm.groupPosts,
          notifications: vm.notifications,
        );

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.tasks,
          child: DoctorAssistantPageScaffold(
            title: 'Smart Task Center',
            subtitle:
                'Create assignments professionally, monitor submissions, and act on academic follow-up from one workspace.',
            breadcrumbs: const ['Workspace', 'Tasks'],
            actions: [
              FilledButton.tonalIcon(
                onPressed: vm.reload,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go(AppRoutes.results),
                icon: const Icon(Icons.fact_check_rounded, size: 18),
                label: const Text('Review Results'),
              ),
            ],
            child: TasksWorkspacePage(
              tasksState: vm.state,
              workspaceData: workspaceData,
              subjects: vm.subjects,
              onReload: vm.reload,
              onSaveTask: vm.save,
            ),
          ),
        );
      },
    );
  }
}

TasksState _stateSelector(DoctorAssistantAppState state) => state.tasksState;

void _onLoad(Store<DoctorAssistantAppState> store) =>
    store.dispatch(LoadTasksAction());

void _onSave(
  Store<DoctorAssistantAppState> store,
  Map<String, dynamic> payload,
) => store.dispatch(SaveTaskAction(payload));

class _TasksScreenVm {
  const _TasksScreenVm({
    required this.user,
    required this.state,
    required this.tasks,
    required this.subjects,
    required this.results,
    required this.announcements,
    required this.students,
    required this.groupPosts,
    required this.notifications,
    required this.reload,
    required this.save,
  });

  final SessionUser? user;
  final TasksState state;
  final List<TaskModel> tasks;
  final List<TeachingSubject> subjects;
  final List<MockStudentResult> results;
  final List<MockAnnouncementItem> announcements;
  final List<MockStudentDirectoryEntry> students;
  final List<MockGroupPost> groupPosts;
  final List<WorkspaceNotificationItem> notifications;
  final VoidCallback reload;
  final ValueChanged<Map<String, dynamic>> save;

  factory _TasksScreenVm.fromStore(Store<DoctorAssistantAppState> store) {
    final user = getCurrentUser(store.state);
    final repository = DoctorAssistantMockRepository.instance;
    final safeUser = user ?? repository.userByEmail('assistant@tolab.edu');
    return _TasksScreenVm(
      user: user,
      state: _stateSelector(store.state),
      tasks: repository.tasksFor(safeUser),
      subjects: repository.subjectsFor(safeUser),
      results: repository.resultsFor(safeUser),
      announcements: repository.announcementsFor(safeUser),
      students: repository.studentsFor(safeUser),
      groupPosts: repository.groupPostsFor(safeUser),
      notifications: repository.notificationsFor(safeUser),
      reload: () => _onLoad(store),
      save: (payload) => _onSave(store, payload),
    );
  }
}
