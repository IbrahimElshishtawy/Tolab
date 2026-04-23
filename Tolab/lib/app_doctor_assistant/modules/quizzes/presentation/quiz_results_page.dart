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
import 'models/quizzes_workspace_models.dart';
import 'widgets/quiz_results_charts.dart';

class QuizResultsPage extends StatelessWidget {
  const QuizResultsPage({super.key, required this.quizId});

  final int quizId;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _ResultsVm>(
      converter: (store) => _ResultsVm.fromStore(store, quizId),
      builder: (context, vm) {
        final user = vm.user;
        final quiz = vm.quiz;
        if (user == null || quiz == null) {
          return const SizedBox.shrink();
        }

        final highestScore = quiz.submissions
            .where((submission) => submission.score != null)
            .fold<double>(
              0,
              (maxValue, item) =>
                  item.score! > maxValue ? item.score! : maxValue,
            );
        final lowestScore = quiz.submissions
            .where((submission) => submission.score != null)
            .fold<double>(
              quiz.totalMarks.toDouble(),
              (minValue, item) =>
                  item.score! < minValue ? item.score! : minValue,
            );

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.quizzes,
          child: DoctorAssistantPageScaffold(
            title: '${quiz.title} Results',
            subtitle:
                '${quiz.subjectLabel} - analytics, completion, distribution, and student scores.',
            breadcrumbs: const <String>['Workspace', 'Quizzes', 'Results'],
            actions: [
              FilledButton.tonalIcon(
                onPressed: () => context.go(AppRoutes.quizPreview(quiz.id)),
                icon: const Icon(Icons.preview_rounded, size: 18),
                label: const Text('Preview'),
              ),
              FilledButton.tonalIcon(
                onPressed: () =>
                    context.go('${AppRoutes.quizzes}?edit=${quiz.id}'),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit'),
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
                      label: 'Pass rate',
                      value: '${quiz.passRate.toStringAsFixed(0)}%',
                    ),
                    _MetricCard(
                      label: 'Average',
                      value: '${quiz.averageScore.toStringAsFixed(0)}%',
                    ),
                    _MetricCard(
                      label: 'Highest',
                      value:
                          '${highestScore.toStringAsFixed(0)} / ${quiz.totalMarks}',
                    ),
                    _MetricCard(
                      label: 'Lowest',
                      value:
                          '${lowestScore.toStringAsFixed(0)} / ${quiz.totalMarks}',
                    ),
                    _MetricCard(
                      label: 'Completed',
                      value: '${quiz.completedStudents}',
                    ),
                    _MetricCard(
                      label: 'Incomplete',
                      value: '${quiz.totalStudents - quiz.completedStudents}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                QuizResultsCharts(quiz: quiz),
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
                        'Students and Scores',
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
                            DataColumn(label: Text('Progress')),
                          ],
                          rows: quiz.submissions
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
                                      SizedBox(
                                        width: 140,
                                        child: LinearProgressIndicator(
                                          value: submission.progress,
                                        ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultsVm {
  const _ResultsVm({required this.user, required this.quiz});

  final SessionUser? user;
  final QuizWorkspaceItem? quiz;

  factory _ResultsVm.fromStore(
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
    return _ResultsVm(user: user, quiz: quiz);
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
