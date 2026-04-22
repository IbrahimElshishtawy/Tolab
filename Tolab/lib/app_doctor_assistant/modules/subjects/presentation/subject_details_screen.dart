import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/core/widgets/app_card.dart';
import '../../../../app_admin/shared/widgets/premium_button.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';

class SubjectDetailsScreen extends StatelessWidget {
  const SubjectDetailsScreen({super.key, required this.subjectId});

  final int subjectId;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) return const SizedBox.shrink();
        final subject = DoctorAssistantMockRepository.instance.subjectById(
          subjectId,
        );

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.subjects,
          unreadNotifications: DoctorAssistantMockRepository.instance
              .unreadNotificationsFor(user),
          child: DefaultTabController(
            length: 4,
            child: DoctorAssistantPageScaffold(
              title: subject.name,
              subtitle: subject.description,
              breadcrumbs: ['Workspace', 'Subjects', subject.code],
              actions: [
                PremiumButton(
                  label: 'Add Lecture',
                  icon: Icons.co_present_rounded,
                  onPressed: () => context.go(AppRoutes.lectures),
                ),
                PremiumButton(
                  label: 'Add Task',
                  icon: Icons.task_alt_rounded,
                  isSecondary: true,
                  onPressed: () => context.go(AppRoutes.tasks),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DoctorAssistantSubjectCard(subject: subject, onTap: () {}),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: const TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        Tab(text: 'Lectures'),
                        Tab(text: 'Sections'),
                        Tab(text: 'Quizzes'),
                        Tab(text: 'Tasks'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 560,
                    child: TabBarView(
                      children: [
                        _DetailList(
                          cards: subject.lectures
                              .map(
                                (lecture) => DoctorAssistantItemCard(
                                  icon: Icons.co_present_rounded,
                                  title: lecture.title,
                                  subtitle:
                                      '${lecture.audience} • ${lecture.room}',
                                  meta:
                                      '${lecture.dayLabel} • ${lecture.timeLabel} • ${lecture.weekLabel}',
                                  statusLabel: lecture.statusLabel,
                                ),
                              )
                              .toList(),
                        ),
                        _DetailList(
                          cards: subject.sections
                              .map(
                                (section) => DoctorAssistantItemCard(
                                  icon: Icons.widgets_rounded,
                                  title: section.title,
                                  subtitle:
                                      '${section.assistantName} • ${section.room}',
                                  meta:
                                      '${section.dayLabel} • ${section.timeLabel} • Group ${section.groupLabel}',
                                  statusLabel: section.statusLabel,
                                ),
                              )
                              .toList(),
                        ),
                        _DetailList(
                          cards: subject.quizzes
                              .map(
                                (quiz) => DoctorAssistantItemCard(
                                  icon: Icons.quiz_rounded,
                                  title: quiz.title,
                                  subtitle:
                                      '${quiz.scopeLabel} • ${quiz.attemptsLabel}',
                                  meta: quiz.windowLabel,
                                  statusLabel: quiz.statusLabel,
                                ),
                              )
                              .toList(),
                        ),
                        _DetailList(
                          cards: subject.tasks
                              .map(
                                (task) => DoctorAssistantItemCard(
                                  icon: Icons.assignment_rounded,
                                  title: task.title,
                                  subtitle:
                                      '${task.scopeLabel} • ${task.progressLabel}',
                                  meta: task.deadlineLabel,
                                  statusLabel: task.statusLabel,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailList extends StatelessWidget {
  const _DetailList({required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const DoctorAssistantEmptyState(
        title: 'No records in this tab',
        subtitle: 'Add a new entry from the action bar to populate this view.',
      );
    }

    return ListView.separated(
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => cards[index],
    );
  }
}
