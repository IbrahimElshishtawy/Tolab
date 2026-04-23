import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/core/widgets/app_card.dart';
import '../../../../app_admin/shared/widgets/premium_button.dart';
import '../../../../app_admin/shared/widgets/status_badge.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/state/async_state.dart';
import '../../../core/widgets/state_views.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../../groups/presentation/widgets/latest_posts_section.dart';
import '../../results/models/results_models.dart';
import '../models/subject_workspace_models.dart';
import '../state/subjects_actions.dart';

class SubjectDetailsScreen extends StatelessWidget {
  const SubjectDetailsScreen({super.key, required this.subjectId});

  final int subjectId;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _SubjectWorkspaceVm>(
      onInit: (store) => store.dispatch(LoadSubjectWorkspaceAction(subjectId)),
      converter: (store) => _SubjectWorkspaceVm.fromStore(store),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) {
          return const SizedBox.shrink();
        }

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.subjects,
          unreadNotifications: 0,
          child: DoctorAssistantPageScaffold(
            title: 'Subject Workspace',
            subtitle:
                'Command center for lectures, sections, quizzes, group activity, students, and grading signals.',
            breadcrumbs: const ['Workspace', 'Subjects', 'Details'],
            scrollable: false,
            child: _buildBody(context, vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, _SubjectWorkspaceVm vm) {
    if (vm.state.status == ViewStatus.loading && vm.state.data == null) {
      return const LoadingStateView(lines: 4);
    }
    if (vm.state.status == ViewStatus.failure && vm.state.data == null) {
      return ErrorStateView(
        message: vm.state.error ?? 'Unable to load subject workspace.',
        onRetry: vm.reload,
      );
    }

    final workspace = vm.state.data;
    if (workspace == null) {
      return const EmptyStateView(
        title: 'Subject not found',
        message: 'The requested subject workspace is unavailable.',
      );
    }

    final subject = workspace.subject;
    return DefaultTabController(
      length: 7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StatusBadge(subject.code),
                    StatusBadge(subject.statusLabel),
                    if (subject.levelLabel.isNotEmpty) StatusBadge(subject.levelLabel),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  subject.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subject.description ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _Stat(label: 'Doctor', value: subject.doctorName ?? '--'),
                    _Stat(label: 'Assistant', value: subject.assistantName ?? '--'),
                    _Stat(label: 'Students', value: '${subject.studentCount}'),
                    _Stat(label: 'Lectures', value: '${subject.lecturesCount}'),
                    _Stat(label: 'Sections', value: '${subject.sectionsCount}'),
                    _Stat(label: 'Quizzes', value: '${subject.quizzesCount}'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    PremiumButton(
                      label: 'Add Lecture',
                      icon: Icons.co_present_rounded,
                      onPressed: () => context.go(
                        '${AppRoutes.addLecture}?subjectId=${subject.id}',
                      ),
                    ),
                    PremiumButton(
                      label: 'Add Section',
                      icon: Icons.widgets_rounded,
                      isSecondary: true,
                      onPressed: () => context.go(AppRoutes.sectionContent),
                    ),
                    PremiumButton(
                      label: 'Add Quiz',
                      icon: Icons.quiz_rounded,
                      isSecondary: true,
                      onPressed: () => context.go(AppRoutes.quizzes),
                    ),
                    PremiumButton(
                      label: 'Add Post',
                      icon: Icons.post_add_rounded,
                      isSecondary: true,
                      onPressed: () => context.go(AppRoutes.addSubjectPost(subject.id)),
                    ),
                    PremiumButton(
                      label: 'View Students',
                      icon: Icons.groups_rounded,
                      isSecondary: true,
                      onPressed: () => context.go(AppRoutes.students),
                    ),
                    PremiumButton(
                      label: 'Open Results',
                      icon: Icons.grading_rounded,
                      isSecondary: true,
                      onPressed: () => context.go(AppRoutes.subjectResults(subject.id)),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                Tab(text: 'Assignments'),
                Tab(text: 'Group'),
                Tab(text: 'Results'),
                Tab(text: 'Students'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              children: [
                _SimpleList(
                  children: workspace.lectures
                      .map(
                        (lecture) => DoctorAssistantItemCard(
                          icon: Icons.co_present_rounded,
                          title: lecture.title,
                          subtitle: lecture.description ?? lecture.instructorName,
                          meta:
                              '${lecture.startsAt ?? lecture.publishedAt ?? 'TBA'} - ${lecture.locationLabel ?? lecture.deliveryMode}',
                          statusLabel: lecture.statusLabel,
                        ),
                      )
                      .toList(growable: false),
                ),
                _SimpleList(
                  children: workspace.sections
                      .map(
                        (section) => DoctorAssistantItemCard(
                          icon: Icons.widgets_rounded,
                          title: section.title,
                          subtitle: section.assistantName,
                          meta:
                              '${section.publishedAt ?? 'Planned'} - ${section.videoUrl ?? section.fileUrl ?? 'Section content'}',
                          statusLabel: section.isPublished ? 'Published' : 'Draft',
                        ),
                      )
                      .toList(growable: false),
                ),
                _SimpleList(
                  children: workspace.quizzes
                      .map(
                        (quiz) => DoctorAssistantItemCard(
                          icon: Icons.quiz_rounded,
                          title: quiz.title,
                          subtitle: quiz.ownerName,
                          meta: quiz.quizDate,
                          statusLabel: quiz.isPublished ? 'Published' : 'Draft',
                        ),
                      )
                      .toList(growable: false),
                ),
                _SimpleList(
                  children: workspace.tasks
                      .map(
                        (task) => DoctorAssistantItemCard(
                          icon: Icons.assignment_rounded,
                          title: task.title,
                          subtitle: task.referenceName,
                          meta: task.dueDate ?? 'Open task',
                          statusLabel: task.isPublished ? 'Published' : 'Draft',
                        ),
                      )
                      .toList(growable: false),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: PremiumButton(
                          label: 'Open full group',
                          icon: Icons.forum_rounded,
                          onPressed: () =>
                              context.go(AppRoutes.subjectGroup(subject.id)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LatestPostsSection(posts: workspace.group.posts.take(3).toList()),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: workspace.results.categories
                            .map((category) => _CategoryCard(category: category))
                            .toList(growable: false),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PremiumButton(
                          label: 'Open grade management',
                          icon: Icons.grading_rounded,
                          onPressed: () =>
                              context.go(AppRoutes.subjectResults(subject.id)),
                        ),
                      ),
                    ],
                  ),
                ),
                _SimpleList(
                  children: workspace.students
                      .map(
                        (student) => DoctorAssistantItemCard(
                          icon: Icons.school_rounded,
                          title: student.name,
                          subtitle: '${student.code} - ${student.sectionLabel}',
                          meta:
                              'Average ${student.averageScore.toStringAsFixed(1)}% - Attendance ${student.attendanceRate}%',
                          statusLabel: student.statusLabel,
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectWorkspaceVm {
  const _SubjectWorkspaceVm({
    required this.user,
    required this.state,
    required this.reload,
  });

  final dynamic user;
  final AsyncState<SubjectWorkspaceModel> state;
  final VoidCallback reload;

  factory _SubjectWorkspaceVm.fromStore(Store<DoctorAssistantAppState> store) {
    final user = getCurrentUser(store.state);
    final currentSubjectId = store.state.subjectsState.workspace.data?.subject.id ?? 0;
    return _SubjectWorkspaceVm(
      user: user,
      state: store.state.subjectsState.workspace,
      reload: () => store.dispatch(LoadSubjectWorkspaceAction(currentSubjectId)),
    );
  }
}

class _SimpleList extends StatelessWidget {
  const _SimpleList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const EmptyStateView(
        title: 'No records yet',
        message: 'This section will populate as the teaching workspace grows.',
      );
    }

    return ListView.separated(
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => children[index],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final GradeCategoryModel category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusBadge(category.statusLabel),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Average ${category.averageScore.toStringAsFixed(1)} / ${category.maxScore.toStringAsFixed(0)}',
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${category.gradedCount} graded - ${category.missingCount} missing',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
