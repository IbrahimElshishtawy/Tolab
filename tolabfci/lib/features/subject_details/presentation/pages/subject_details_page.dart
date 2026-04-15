import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../staff_portal/presentation/pages/staff_subject_workspace_page.dart';
import '../../../../core/models/quiz_models.dart';
import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
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
import '../widgets/subject_details_header.dart';
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

    return SafeArea(
      child: AdaptivePageContainer(
        child: subjectAsync.when(
          data: (subject) {
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
                  SubjectDetailsHeader(subject: subject),
                  const SizedBox(height: AppSpacing.lg),
                  _CurrentRequiredActions(
                    tasksAsync: tasksAsync,
                    quizzesAsync: quizzesAsync,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: tabs.map((tab) => Tab(text: tab.$2)).toList(),
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
          loading: () => const LoadingWidget(label: 'جاري تحميل المادة...'),
          error: (error, stackTrace) =>
              ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _CurrentRequiredActions extends StatelessWidget {
  const _CurrentRequiredActions({
    required this.tasksAsync,
    required this.quizzesAsync,
  });

  final AsyncValue<List<TaskItem>> tasksAsync;
  final AsyncValue<List<QuizItem>> quizzesAsync;

  @override
  Widget build(BuildContext context) {
    final tasks = tasksAsync.asData?.value ?? const [];
    final quizzes = quizzesAsync.asData?.value ?? const [];
    final pendingTask = tasks
        .where((task) => task.isCompleted == false)
        .firstOrNull;
    final openQuiz = quizzes
        .where(
          (quiz) =>
              quiz.startsAt != null &&
              quiz.closesAt != null &&
              !quiz.startsAt!.isAfter(DateTime.now()) &&
              quiz.closesAt!.isAfter(DateTime.now()) &&
              quiz.isSubmitted == false,
        )
        .firstOrNull;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('المطلوب الآن', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            openQuiz != null
                ? 'يوجد كويز مفتوح الآن يحتاج دخولًا.'
                : pendingTask != null
                ? 'أقرب خطوة مهمة هي استكمال الشيتات المعلقة.'
                : 'أنت متابع المادة جيدًا حاليًا.',
            style: Theme.of(context).textTheme.bodySmall,
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
