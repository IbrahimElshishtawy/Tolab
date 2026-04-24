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
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';
import '../../../quizzes/presentation/providers/quizzes_providers.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';
import '../widgets/files_tab.dart';
import '../widgets/grades_tab.dart';
import '../widgets/group_tab.dart';
import '../widgets/lectures_tab.dart';
import '../widgets/quizzes_tab.dart';
import '../widgets/sections_tab.dart';
import '../widgets/summaries_tab.dart';
import '../widgets/tasks_tab.dart';

class SubjectDetailsPage extends ConsumerWidget {
  const SubjectDetailsPage({
    super.key,
    required this.subjectId,
    this.initialTab,
  });

  final String subjectId;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStaff = ref.watch(isStaffUserProvider);
    if (isStaff) {
      return StaffSubjectWorkspacePage(subjectId: subjectId);
    }

    final subjectAsync = ref.watch(subjectByIdProvider(subjectId));
    final tasksAsync = ref.watch(tasksProvider(subjectId));
    final quizzesAsync = ref.watch(quizzesProvider(subjectId));
    final lecturesAsync = ref.watch(lecturesProvider(subjectId));

    return SafeArea(
      child: AdaptivePageContainer(
        child: subjectAsync.when(
          data: (subject) {
            final tasks = tasksAsync.asData?.value ?? const <TaskItem>[];
            final quizzes = quizzesAsync.asData?.value ?? const <QuizItem>[];
            final lectures =
                lecturesAsync.asData?.value ?? const <LectureItem>[];
            final tabs = const [
              ('lectures', 'المحاضرات'),
              ('sections', 'السكاشن'),
              ('quizzes', 'الكويزات'),
              ('tasks', 'الشيتات'),
              ('summaries', 'الملخصات'),
              ('files', 'الملفات'),
              ('group', 'الجروب'),
              ('grades', 'الدرجات'),
            ];

            return DefaultTabController(
              length: tabs.length,
              initialIndex: _tabIndex(initialTab, tabs),
              child: Column(
                children: [
                  _WorkspaceHeader(
                    subject: subject,
                    lectureCount: lectures.length,
                    quizCount: quizzes.length,
                    taskCount: tasks.length,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _CurrentFocusStrip(
                    subject: subject,
                    tasks: tasks,
                    quizzes: quizzes,
                    lectures: lectures,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _QuickActionsRow(
                    subjectId: subjectId,
                    quizzes: quizzes,
                    tasks: tasks,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [for (final tab in tabs) Tab(text: tab.$2)],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: TabBarView(
                      children: [
                        LecturesTab(subjectId: subjectId),
                        SectionsTab(subjectId: subjectId),
                        QuizzesTab(subjectId: subjectId),
                        TasksTab(subjectId: subjectId),
                        SummariesTab(subjectId: subjectId),
                        FilesTab(subjectId: subjectId),
                        GroupTab(subjectId: subjectId),
                        GradesTab(subjectId: subjectId),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () =>
              const LoadingWidget(label: 'جارٍ تحميل مساحة المادة...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.subject,
    required this.lectureCount,
    required this.quizCount,
    required this.taskCount,
  });

  final SubjectOverview subject;
  final int lectureCount;
  final int quizCount;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(subject.accentHex);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [accent.withValues(alpha: 0.18), context.appColors.surface],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(subject.description),
                    ],
                  ),
                ),
                AppBadge(
                  label: subject.status,
                  backgroundColor: accent.withValues(alpha: 0.14),
                  foregroundColor: accent,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppBadge(label: subject.code, backgroundColor: Colors.white),
                AppBadge(
                  label: subject.instructor,
                  backgroundColor: Colors.white,
                ),
                AppBadge(
                  label: 'المعيد ${subject.assistantName}',
                  backgroundColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ResponsiveWrapGrid(
              minItemWidth: 140,
              spacing: AppSpacing.sm,
              children: [
                _HeaderStat(
                  label: 'التقدم',
                  value: '${(subject.progress * 100).round()}%',
                ),
                _HeaderStat(label: 'المحاضرات', value: '$lectureCount'),
                _HeaderStat(label: 'الكويزات', value: '$quizCount'),
                _HeaderStat(label: 'التكليفات', value: '$taskCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentFocusStrip extends StatelessWidget {
  const _CurrentFocusStrip({
    required this.subject,
    required this.tasks,
    required this.quizzes,
    required this.lectures,
  });

  final SubjectOverview subject;
  final List<TaskItem> tasks;
  final List<QuizItem> quizzes;
  final List<LectureItem> lectures;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final openQuiz = quizzes.cast<QuizItem?>().firstWhere(
      (quiz) =>
          quiz != null &&
          quiz.startsAt != null &&
          quiz.closesAt != null &&
          !quiz.startsAt!.isAfter(now) &&
          quiz.closesAt!.isAfter(now) &&
          !quiz.isSubmitted,
      orElse: () => null,
    );
    final lateTask = tasks.cast<TaskItem?>().firstWhere(
      (task) =>
          task != null &&
          !task.isCompleted &&
          task.dueAt != null &&
          task.dueAt!.isBefore(now),
      orElse: () => null,
    );
    final nextLecture = lectures.cast<LectureItem?>().firstWhere(
      (lecture) => lecture?.startsAt?.isAfter(now) ?? false,
      orElse: () => null,
    );

    return ResponsiveWrapGrid(
      minItemWidth: 240,
      children: [
        _FocusCard(
          title: 'كويز مفتوح',
          body: openQuiz?.title ?? 'لا يوجد كويز مفتوح الآن',
          accent: AppColors.error,
        ),
        _FocusCard(
          title: 'شيت يحتاج متابعة',
          body: lateTask?.title ?? 'لا توجد تكليفات متأخرة حاليًا',
          accent: AppColors.warning,
        ),
        _FocusCard(
          title: 'محاضرة قادمة',
          body: nextLecture?.title ?? 'لا توجد محاضرة قريبة داخل المادة',
          accent: AppColors.primary,
        ),
        _FocusCard(
          title: 'آخر نشاط',
          body: subject.lastActivityLabel,
          accent: AppColors.success,
        ),
      ],
    );
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
          label: 'فتح كويز',
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

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
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

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.title,
    required this.body,
    required this.accent,
  });

  final String title;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBadge(
            label: title,
            backgroundColor: accent.withValues(alpha: 0.12),
            foregroundColor: accent,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

int _tabIndex(String? initialTab, List<(String, String)> tabs) {
  final index = tabs.indexWhere((tab) => tab.$1 == initialTab);
  return index < 0 ? 0 : index;
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

Color _accentColor(String hex) {
  final sanitized = hex.replaceAll('#', '');
  return Color(int.parse('FF$sanitized', radix: 16));
}
