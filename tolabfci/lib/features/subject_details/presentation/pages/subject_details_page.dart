import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../staff_portal/presentation/pages/staff_subject_workspace_page.dart';
import '../../../../core/models/quiz_models.dart';
import '../../../../core/models/subject_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../quizzes/presentation/providers/quizzes_providers.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';
import '../widgets/files_tab.dart';
import '../widgets/grades_tab.dart';
import '../widgets/group_tab.dart';
import '../widgets/lectures_tab.dart';
import '../widgets/quizzes_tab.dart';
import '../widgets/sections_tab.dart';
import '../widgets/subject_header_card.dart';
import '../widgets/subject_required_now_section.dart';
import '../widgets/subject_tabs.dart';
import '../widgets/summaries_tab.dart';
import '../widgets/tasks_tab.dart';

class SubjectDetailsPage extends ConsumerStatefulWidget {
  const SubjectDetailsPage({
    super.key,
    required this.subjectId,
    this.initialTab,
  });

  final String subjectId;
  final String? initialTab;

  @override
  ConsumerState<SubjectDetailsPage> createState() => _SubjectDetailsPageState();
}

class _SubjectDetailsPageState extends ConsumerState<SubjectDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = SubjectTabs.indexFor(widget.initialTab);
    _tabController = TabController(
      length: SubjectTabs.items.length,
      vsync: this,
      initialIndex: _selectedIndex,
    );
  }

  @override
  void didUpdateWidget(covariant SubjectDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = SubjectTabs.indexFor(widget.initialTab);
    if (nextIndex == _selectedIndex) {
      return;
    }
    _selectedIndex = nextIndex;
    _tabController.index = nextIndex;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = ref.watch(isStaffUserProvider);
    if (isStaff) {
      return StaffSubjectWorkspacePage(subjectId: widget.subjectId);
    }

    final subjectAsync = ref.watch(subjectByIdProvider(widget.subjectId));
    final tasksAsync = ref.watch(tasksProvider(widget.subjectId));
    final quizzesAsync = ref.watch(quizzesProvider(widget.subjectId));
    final lecturesAsync = ref.watch(lecturesProvider(widget.subjectId));

    return SafeArea(
      child: AdaptivePageContainer(
        child: subjectAsync.when(
          data: (subject) {
            final tasks = tasksAsync.asData?.value ?? const <TaskItem>[];
            final quizzes = quizzesAsync.asData?.value ?? const <QuizItem>[];
            final lectures =
                lecturesAsync.asData?.value ?? const <LectureItem>[];

            return ListView(
              children: [
                SubjectHeaderCard(
                  subject: subject,
                  lectureCount: lectures.length,
                  quizCount: quizzes.length,
                  taskCount: tasks.length,
                ),
                const SizedBox(height: AppSpacing.md),
                SubjectRequiredNowSection(
                  subject: subject,
                  tasks: tasks,
                  quizzes: quizzes,
                  lectures: lectures,
                ),
                const SizedBox(height: AppSpacing.md),
                _QuickActionsRow(
                  subjectId: widget.subjectId,
                  quizzes: quizzes,
                  tasks: tasks,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: context.appColors.border),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    onTap: (index) {
                      if (index == _selectedIndex) {
                        return;
                      }
                      setState(() => _selectedIndex = index);
                    },
                    tabs: [
                      for (final tab in SubjectTabs.items) Tab(text: tab.$2),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: KeyedSubtree(
                    key: ValueKey(SubjectTabs.items[_selectedIndex].$1),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            );
          },
          loading: () =>
              const LoadingWidget(label: 'جارٍ تحميل مساحة المادة...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (SubjectTabs.items[_selectedIndex].$1) {
      'lectures' => LecturesTab(
        subjectId: widget.subjectId,
        usePageScroll: true,
      ),
      'sections' => SectionsTab(
        subjectId: widget.subjectId,
        usePageScroll: true,
      ),
      'quizzes' => QuizzesTab(subjectId: widget.subjectId, usePageScroll: true),
      'tasks' => TasksTab(subjectId: widget.subjectId, usePageScroll: true),
      'summaries' => SummariesTab(
        subjectId: widget.subjectId,
        usePageScroll: true,
      ),
      'files' => FilesTab(subjectId: widget.subjectId, usePageScroll: true),
      'group' => GroupTab(subjectId: widget.subjectId, usePageScroll: true),
      'grades' => GradesTab(subjectId: widget.subjectId, usePageScroll: true),
      _ => LecturesTab(subjectId: widget.subjectId, usePageScroll: true),
    };
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.subjectId,
    required this.quizzes,
    required this.tasks,
  });

  final String subjectId;
  final List<QuizItem> quizzes;
  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    final openQuiz = quizzes.firstWhere(
      (quiz) => _isQuizOpen(quiz),
      orElse: () => quizzes.isEmpty ? _emptyQuiz : quizzes.first,
    );
    final pendingTask = tasks.firstWhere(
      (task) => !task.isCompleted,
      orElse: () => tasks.isEmpty ? _emptyTask : tasks.first,
    );

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        AppButton(
          label: 'المحاضرات',
          onPressed: () => _openTab(context, 'lectures'),
          isExpanded: false,
          icon: Icons.play_circle_outline_rounded,
        ),
        AppButton(
          label: 'فتح الكويز',
          onPressed: openQuiz.id.isEmpty
              ? null
              : () => context.goNamed(
                  RouteNames.quizEntry,
                  pathParameters: {
                    'subjectId': subjectId,
                    'quizId': openQuiz.id,
                  },
                ),
          isExpanded: false,
          variant: AppButtonVariant.secondary,
          icon: Icons.quiz_outlined,
        ),
        AppButton(
          label: 'رفع شيت',
          onPressed: pendingTask.id.isEmpty
              ? null
              : () => context.goNamed(
                  RouteNames.assignmentUpload,
                  pathParameters: {
                    'subjectId': subjectId,
                    'taskId': pendingTask.id,
                  },
                ),
          isExpanded: false,
          variant: AppButtonVariant.secondary,
          icon: Icons.upload_file_rounded,
        ),
        AppButton(
          label: 'الجروب',
          onPressed: () => _openTab(context, 'group'),
          isExpanded: false,
          variant: AppButtonVariant.secondary,
          icon: Icons.forum_outlined,
        ),
        AppButton(
          label: 'الدرجات',
          onPressed: () => _openTab(context, 'grades'),
          isExpanded: false,
          variant: AppButtonVariant.secondary,
          icon: Icons.bar_chart_rounded,
        ),
      ],
    );
  }

  void _openTab(BuildContext context, String tab) {
    context.goNamed(
      RouteNames.subjectDetails,
      pathParameters: {'subjectId': subjectId},
      queryParameters: {'tab': tab},
    );
  }
}

bool _isQuizOpen(QuizItem quiz) {
  final now = DateTime.now();
  return quiz.startsAt != null &&
      quiz.closesAt != null &&
      !quiz.startsAt!.isAfter(now) &&
      quiz.closesAt!.isAfter(now) &&
      !quiz.isSubmitted;
}

final _emptyQuiz = QuizItem(
  id: '',
  subjectId: '',
  title: '',
  typeLabel: '',
  startAtLabel: '',
  durationLabel: '',
  isOnline: true,
  instructions: const [],
);

final _emptyTask = TaskItem(
  id: '',
  subjectId: '',
  title: '',
  description: '',
  dueDateLabel: '',
  status: '',
);
