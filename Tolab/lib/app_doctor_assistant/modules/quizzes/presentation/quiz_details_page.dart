import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../modules/auth/state/session_selectors.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../state/quizzes_actions.dart';
import 'models/quizzes_workspace_models.dart';

class QuizDetailsPage extends StatefulWidget {
  const QuizDetailsPage({super.key, required this.quizId});

  final int quizId;

  @override
  State<QuizDetailsPage> createState() => _QuizDetailsPageState();
}

class _QuizDetailsPageState extends State<QuizDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _QuizRouteVm>(
      converter: (store) => _QuizRouteVm.fromStore(store, widget.quizId),
      builder: (context, vm) {
        final user = vm.user;
        final quiz = vm.quiz;
        if (user == null) {
          return const SizedBox.shrink();
        }
        if (quiz == null) {
          return DoctorAssistantShell(
            user: user,
            activeRoute: AppRoutes.quizzes,
            child: const DoctorAssistantPageScaffold(
              title: 'Quiz not found',
              subtitle:
                  'The selected quiz is no longer available in the local workspace.',
              breadcrumbs: <String>['Workspace', 'Quizzes'],
              child: SizedBox.shrink(),
            ),
          );
        }

        final quickInsights = <String>[
          '${quiz.notStartedStudents} students have not started yet.',
          if (quiz.passRate < 65)
            'Pass rate is low at ${quiz.passRate.toStringAsFixed(0)}%.',
          if (quiz.averageScore < 60)
            'Average score is ${quiz.averageScore.toStringAsFixed(0)}%, below the expected threshold.',
          if (quiz.isOpen)
            '${quiz.liveParticipants} students are currently active inside the quiz.',
        ];

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.quizzes,
          child: DoctorAssistantPageScaffold(
            title: quiz.title,
            subtitle:
                '${quiz.subjectLabel} - ${quiz.statusLabel} - ${quiz.startLabel} to ${quiz.endLabel}',
            breadcrumbs: const <String>['Workspace', 'Quizzes', 'Details'],
            actions: [
              FilledButton.tonalIcon(
                onPressed: () =>
                    context.go('${AppRoutes.quizzes}?edit=${quiz.id}'),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go(AppRoutes.quizPreview(quiz.id)),
                icon: const Icon(Icons.preview_rounded, size: 18),
                label: const Text('Preview'),
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  if (quiz.isOpen) {
                    vm.closeQuiz();
                  } else {
                    vm.publishQuiz();
                  }
                  setState(() {});
                },
                icon: Icon(
                  quiz.isOpen
                      ? Icons.stop_circle_rounded
                      : Icons.publish_rounded,
                  size: 18,
                ),
                label: Text(quiz.isOpen ? 'Close' : 'Publish'),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      label: 'Students',
                      value: '${quiz.totalStudents}',
                    ),
                    _MetricCard(
                      label: 'Started',
                      value: '${quiz.enteredStudents}',
                    ),
                    _MetricCard(
                      label: 'Completed',
                      value: '${quiz.completedStudents}',
                    ),
                    _MetricCard(
                      label: 'Pass rate',
                      value: '${quiz.passRate.toStringAsFixed(0)}%',
                    ),
                    _MetricCard(
                      label: 'Average',
                      value: '${quiz.averageScore.toStringAsFixed(0)}%',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Questions Preview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      for (
                        var index = 0;
                        index < quiz.questions.length;
                        index++
                      ) ...[
                        _QuestionPreviewCard(
                          index: index,
                          question: quiz.questions[index],
                          onEdit: () => context.go(
                            '${AppRoutes.quizzes}?edit=${quiz.id}',
                          ),
                          onDelete: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Delete question from the builder edit flow.',
                                ),
                              ),
                            );
                          },
                        ),
                        if (index != quiz.questions.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Students / Submissions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Student')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Score')),
                            DataColumn(label: Text('Submitted')),
                          ],
                          rows: quiz.submissions
                              .take(12)
                              .map(
                                (submission) => DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        '${submission.studentName}\n${submission.studentCode}',
                                      ),
                                    ),
                                    DataCell(Text(submission.statusLabel)),
                                    DataCell(
                                      Text(
                                        submission.score == null
                                            ? '--'
                                            : '${submission.score!.toStringAsFixed(0)} / ${quiz.totalMarks}',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        submission.submittedAt == null
                                            ? '--'
                                            : submission.submittedAt.toString(),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Insights',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      for (final item in quickInsights)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.insights_rounded, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuizRouteVm {
  const _QuizRouteVm({
    required this.user,
    required this.quiz,
    required this.publishQuiz,
    required this.closeQuiz,
  });

  final SessionUser? user;
  final QuizWorkspaceItem? quiz;
  final VoidCallback publishQuiz;
  final VoidCallback closeQuiz;

  factory _QuizRouteVm.fromStore(
    Store<DoctorAssistantAppState> store,
    int quizId,
  ) {
    final user = getCurrentUser(store.state);
    final repository = DoctorAssistantMockRepository.instance;
    final safeUser = user ?? repository.userByEmail('doctor@tolab.edu');
    final data = buildQuizzesWorkspaceData(
      subjects: repository.subjectsFor(safeUser),
      results: repository.resultsFor(safeUser),
      students: repository.studentsFor(safeUser),
      notifications: repository.notificationsFor(safeUser),
      announcements: repository.announcementsFor(safeUser),
    );
    QuizWorkspaceItem? quiz;
    for (final item in data.quizzes) {
      if (item.id == quizId) {
        quiz = item;
        break;
      }
    }
    return _QuizRouteVm(
      user: user,
      quiz: quiz,
      publishQuiz: () {
        repository.publishQuiz(quizId);
        store.dispatch(LoadQuizzesAction());
      },
      closeQuiz: () {
        repository.closeQuiz(quizId);
        store.dispatch(LoadQuizzesAction());
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _QuestionPreviewCard extends StatelessWidget {
  const _QuestionPreviewCard({
    required this.index,
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final QuizWorkspaceQuestion question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. ${question.prompt}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${question.type} - ${question.marks} mark${question.marks == 1 ? '' : 's'}',
          ),
          if (question.options.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...question.options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      question.correctAnswers.contains(option)
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(option)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit question'),
              ),
              FilledButton.tonalIcon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
