import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
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
import '../state/quizzes_actions.dart';
import '../state/quizzes_state.dart';
import 'models/quizzes_workspace_models.dart';
import 'widgets/quizzes_workspace_page.dart';

class QuizzesScreen extends StatelessWidget {
  const QuizzesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _QuizzesScreenVm>(
      onInit: _onLoad,
      converter: _QuizzesScreenVm.fromStore,
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) {
          return const SizedBox.shrink();
        }

        final workspaceData = buildQuizzesWorkspaceData(
          subjects: vm.subjects,
          results: vm.results,
          students: vm.students,
          notifications: vm.notifications,
          announcements: vm.announcements,
        );
        final initialEditQuizId = int.tryParse(
          GoRouterState.of(context).uri.queryParameters['edit'] ?? '',
        );

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.quizzes,
          child: DoctorAssistantPageScaffold(
            title: 'Quiz Management Workspace',
            subtitle:
                'Build assessments, monitor live windows, and read performance signals from one premium academic workspace.',
            breadcrumbs: const ['Workspace', 'Quizzes'],
            actions: [
              FilledButton.tonalIcon(
                onPressed: vm.reload,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go(AppRoutes.results),
                icon: const Icon(Icons.insights_rounded, size: 18),
                label: const Text('Open Results'),
              ),
            ],
            child: QuizzesWorkspacePage(
              quizzesState: vm.state,
              workspaceData: workspaceData,
              subjects: vm.subjects,
              initialEditQuizId: initialEditQuizId,
              onReload: vm.reload,
              onSaveQuiz: vm.save,
              onPublishQuiz: vm.publishQuiz,
              onCloseQuiz: vm.closeQuiz,
              onDuplicateQuiz: vm.duplicateQuiz,
            ),
          ),
        );
      },
    );
  }
}

QuizzesState _stateSelector(DoctorAssistantAppState state) =>
    state.quizzesState;

void _onLoad(Store<DoctorAssistantAppState> store) =>
    store.dispatch(LoadQuizzesAction());

void _onSave(
  Store<DoctorAssistantAppState> store,
  Map<String, dynamic> payload,
) => store.dispatch(SaveQuizAction(payload));

class _QuizzesScreenVm {
  const _QuizzesScreenVm({
    required this.user,
    required this.state,
    required this.subjects,
    required this.results,
    required this.students,
    required this.notifications,
    required this.announcements,
    required this.reload,
    required this.save,
    required this.publishQuiz,
    required this.closeQuiz,
    required this.duplicateQuiz,
  });

  final SessionUser? user;
  final QuizzesState state;
  final List<TeachingSubject> subjects;
  final List<MockStudentResult> results;
  final List<MockStudentDirectoryEntry> students;
  final List<WorkspaceNotificationItem> notifications;
  final List<MockAnnouncementItem> announcements;
  final VoidCallback reload;
  final ValueChanged<Map<String, dynamic>> save;
  final ValueChanged<int> publishQuiz;
  final ValueChanged<int> closeQuiz;
  final ValueChanged<int> duplicateQuiz;

  factory _QuizzesScreenVm.fromStore(Store<DoctorAssistantAppState> store) {
    final user = getCurrentUser(store.state);
    final repository = DoctorAssistantMockRepository.instance;
    final safeUser = user ?? repository.userByEmail('doctor@tolab.edu');
    return _QuizzesScreenVm(
      user: user,
      state: _stateSelector(store.state),
      subjects: repository.subjectsFor(safeUser),
      results: repository.resultsFor(safeUser),
      students: repository.studentsFor(safeUser),
      notifications: repository.notificationsFor(safeUser),
      announcements: repository.announcementsFor(safeUser),
      reload: () => _onLoad(store),
      save: (payload) => _onSave(store, payload),
      publishQuiz: (quizId) {
        repository.publishQuiz(quizId);
        _onLoad(store);
      },
      closeQuiz: (quizId) {
        repository.closeQuiz(quizId);
        _onLoad(store);
      },
      duplicateQuiz: (quizId) {
        repository.duplicateQuiz(quizId);
        _onLoad(store);
      },
    );
  }
}
