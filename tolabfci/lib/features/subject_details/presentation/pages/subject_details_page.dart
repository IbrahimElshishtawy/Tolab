import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/models/quiz_models.dart';
import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../quizzes/presentation/providers/quizzes_providers.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';
import '../widgets/grades_tab.dart';
import '../widgets/group_tab.dart';
import '../widgets/lectures_tab.dart';
import '../widgets/quizzes_tab.dart';
import '../widgets/sections_tab.dart';
import '../widgets/subject_group_chat_tab.dart';
import '../widgets/subject_header_card.dart';
import '../widgets/subject_overview_tab.dart';
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
    if (isStaff) {}

    final subjectAsync = ref.watch(subjectByIdProvider(widget.subjectId));
    final tasksAsync = ref.watch(tasksProvider(widget.subjectId));
    final quizzesAsync = ref.watch(quizzesProvider(widget.subjectId));
    final lecturesAsync = ref.watch(lecturesProvider(widget.subjectId));
    final sectionsAsync = ref.watch(sectionsProvider(widget.subjectId));

    return SafeArea(
      child: AdaptivePageContainer(
        child: subjectAsync.when(
          data: (subject) {
            final tasks = tasksAsync.asData?.value ?? const <TaskItem>[];
            final quizzes = quizzesAsync.asData?.value ?? const <QuizItem>[];
            final lectures =
                lecturesAsync.asData?.value ?? const <LectureItem>[];
            final sections =
                sectionsAsync.asData?.value ?? const <SectionItem>[];

            return ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
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
                  sections: sections,
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
      'overview' => SubjectOverviewTab(
        subjectId: widget.subjectId,
        usePageScroll: true,
      ),
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
      'grades' => GradesTab(subjectId: widget.subjectId, usePageScroll: true),
      'community' => GroupTab(subjectId: widget.subjectId, usePageScroll: true),
      'chat' => SubjectGroupChatTab(
        subjectId: widget.subjectId,
        usePageScroll: true,
      ),
      _ => SubjectOverviewTab(subjectId: widget.subjectId, usePageScroll: true),
    };
  }
}
