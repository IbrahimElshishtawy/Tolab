import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../modules/auth/state/session_selectors.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import 'models/quizzes_workspace_models.dart';

class QuizPreviewPage extends StatefulWidget {
  const QuizPreviewPage({super.key, required this.quizId});

  final int quizId;

  @override
  State<QuizPreviewPage> createState() => _QuizPreviewPageState();
}

class _QuizPreviewPageState extends State<QuizPreviewPage> {
  final Map<String, dynamic> _answers = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _PreviewVm>(
      converter: (store) => _PreviewVm.fromStore(store, widget.quizId),
      builder: (context, vm) {
        final user = vm.user;
        final quiz = vm.quiz;
        if (user == null || quiz == null) {
          return const SizedBox.shrink();
        }

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.quizzes,
          child: DoctorAssistantPageScaffold(
            title: '${quiz.title} Preview',
            subtitle:
                'Student-facing preview mode. Answers are local only and will not be saved.',
            breadcrumbs: const <String>['Workspace', 'Quizzes', 'Preview'],
            actions: [
              FilledButton.tonalIcon(
                onPressed: () => setState(() => _answers.clear()),
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Reset'),
              ),
            ],
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(quiz.description),
                  const SizedBox(height: 12),
                  Text(
                    '${quiz.questionCount} questions - ${quiz.totalMarks} marks - ${quiz.durationLabel}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  for (
                    var index = 0;
                    index < quiz.questions.length;
                    index++
                  ) ...[
                    _PreviewQuestionCard(
                      index: index,
                      question: quiz.questions[index],
                      answer: _answers[quiz.questions[index].id],
                      onChanged: (value) {
                        setState(
                          () => _answers[quiz.questions[index].id] = value,
                        );
                      },
                    ),
                    if (index != quiz.questions.length - 1)
                      const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreviewVm {
  const _PreviewVm({required this.user, required this.quiz});

  final SessionUser? user;
  final QuizWorkspaceItem? quiz;

  factory _PreviewVm.fromStore(
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
    return _PreviewVm(user: user, quiz: quiz);
  }
}

class _PreviewQuestionCard extends StatelessWidget {
  const _PreviewQuestionCard({
    required this.index,
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final int index;
  final QuizWorkspaceQuestion question;
  final dynamic answer;
  final ValueChanged<dynamic> onChanged;

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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (question.type == 'multiple_choice' ||
              question.type == 'true_false')
            ...question.options.map(
              (option) => InkWell(
                onTap: () => onChanged(option),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        (answer as String?) == option
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(option)),
                    ],
                  ),
                ),
              ),
            )
          else if (question.type == 'checkbox')
            ...question.options.map((option) {
              final selected = (answer as List<String>? ?? const <String>[])
                  .contains(option);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(option),
                value: selected,
                onChanged: (value) {
                  final next = List<String>.from(
                    answer as List<String>? ?? const <String>[],
                  );
                  if (value == true) {
                    next.add(option);
                  } else {
                    next.remove(option);
                  }
                  onChanged(next);
                },
              );
            })
          else
            TextField(
              minLines: question.type == 'paragraph' ? 4 : 1,
              maxLines: question.type == 'paragraph' ? 6 : 1,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Preview answer area',
              ),
            ),
        ],
      ),
    );
  }
}
