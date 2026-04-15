import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/models/staff_portal_models.dart';
import '../providers/staff_portal_providers.dart';
import 'add_announcement_page.dart';
import 'add_lecture_page.dart';
import 'add_quiz_page.dart';
import 'add_section_page.dart';
import 'announcements_page.dart';
import 'course_analytics_page.dart';
import 'course_students_page.dart';
import 'group_activity_page.dart';
import 'quiz_builder_page.dart';
import 'schedule_event_page.dart';

class StaffSubjectWorkspacePage extends ConsumerWidget {
  const StaffSubjectWorkspacePage({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(staffSubjectWorkspaceProvider(subjectId));

    return SafeArea(
      child: AdaptivePageContainer(
        child: workspaceAsync.when(
          data: (workspace) {
            final tabs = [
              context.tr('نظرة عامة', 'Overview'),
              context.tr('الكويزات', 'Quizzes'),
              context.tr('الإعلانات', 'Announcements'),
              context.tr('الجروب', 'Group'),
              context.tr('الجلسات', 'Sessions'),
              context.tr('المواعيد', 'Schedule'),
              context.tr('الطلبة', 'Students'),
              context.tr('التحليلات', 'Analytics'),
            ];

            return DefaultTabController(
              length: tabs.length,
              child: Column(
                children: [
                  _WorkspaceHeader(subject: workspace.subject),
                  const SizedBox(height: AppSpacing.lg),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        AppButton(
                          label: context.tr('إضافة كويز', 'Add quiz'),
                          icon: Icons.quiz_outlined,
                          isExpanded: false,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddQuizPage(subjectId: subjectId),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                          label: context.tr('إعلان جديد', 'New announcement'),
                          icon: Icons.campaign_outlined,
                          variant: AppButtonVariant.secondary,
                          isExpanded: false,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddAnnouncementPage(subjectId: subjectId),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                          label: context.tr('رابط محاضرة', 'Lecture link'),
                          icon: Icons.smart_display_rounded,
                          variant: AppButtonVariant.secondary,
                          isExpanded: false,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddLecturePage(subjectId: subjectId),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                          label: context.tr('رابط سكشن', 'Section link'),
                          icon: Icons.developer_board_rounded,
                          variant: AppButtonVariant.secondary,
                          isExpanded: false,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddSectionPage(subjectId: subjectId),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: tabs.map((label) => Tab(text: label)).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _OverviewTab(workspace: workspace),
                        _QuizzesTab(
                          subjectId: subjectId,
                          quizzes: workspace.quizzes,
                        ),
                        SingleChildScrollView(
                          key: const PageStorageKey('announcements-tab'),
                          child: AnnouncementsPage(
                            subjectId: subjectId,
                            items: workspace.announcements,
                          ),
                        ),
                        SingleChildScrollView(
                          key: const PageStorageKey('group-tab'),
                          child: GroupActivityPage(
                            subjectId: subjectId,
                            posts: workspace.posts,
                          ),
                        ),
                        SingleChildScrollView(
                          key: const PageStorageKey('sessions-tab'),
                          child: _SessionsTab(
                            subjectId: subjectId,
                            lectures: workspace.lectures,
                            sections: workspace.sections,
                          ),
                        ),
                        SingleChildScrollView(
                          key: const PageStorageKey('schedule-tab'),
                          child: _ScheduleTab(
                            subjectId: subjectId,
                            events: workspace.schedule,
                          ),
                        ),
                        SingleChildScrollView(
                          key: const PageStorageKey('students-tab'),
                          child: CourseStudentsPage(
                            students: workspace.students,
                          ),
                        ),
                        SingleChildScrollView(
                          key: const PageStorageKey('analytics-tab'),
                          child: CourseAnalyticsPage(
                            analytics: workspace.analytics,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () =>
              const LoadingWidget(label: 'Loading subject workspace...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({required this.subject});

  final StaffCourseSummary subject;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${subject.code} • ${subject.department} • ${subject.sectionLabel}',
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(
                      'FF${subject.accentHex.replaceAll('#', '')}',
                      radix: 16,
                    ),
                  ).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(subject.roleLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _HeaderMetric(
                label: context.tr('الطلبة', 'Students'),
                value: '${subject.studentCount}',
              ),
              _HeaderMetric(
                label: context.tr('نشطون', 'Active'),
                value: '${subject.activeStudents}',
              ),
              _HeaderMetric(
                label: context.tr('الصحة', 'Health'),
                value: '${subject.healthScore}',
              ),
              _HeaderMetric(
                label: context.tr('التسليمات المعلقة', 'Pending'),
                value: '${subject.pendingSubmissions}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.workspace});

  final StaffSubjectWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('overview-tab'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (workspace.actionRequired.isNotEmpty) ...[
            Text(
              context.tr('Action Center', 'Action Center'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ...workspace.actionRequired.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(item.description),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            context.tr('Upcoming Sessions', 'Upcoming Sessions'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          ...[...workspace.lectures, ...workspace.sections]
              .take(4)
              .map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SessionCard(session: session),
                ),
              ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.tr('Latest Announcements', 'Latest Announcements'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          ...workspace.announcements
              .take(3)
              .map(
                (announcement) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(announcement.content),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _QuizzesTab extends StatelessWidget {
  const _QuizzesTab({required this.subjectId, required this.quizzes});

  final String subjectId;
  final List<StaffQuiz> quizzes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('quizzes-tab'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...quizzes.map(
            (quiz) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            quiz.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (quiz.status == StaffQuizStatus.published
                                        ? AppColors.success
                                        : AppColors.warning)
                                    .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            quiz.status == StaffQuizStatus.published
                                ? context.tr('منشور', 'Published')
                                : context.tr('مسودة', 'Draft'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(quiz.description),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _HeaderMetric(
                          label: context.tr('أسئلة', 'Questions'),
                          value: '${quiz.questionCount}',
                        ),
                        _HeaderMetric(
                          label: context.tr('درجات', 'Marks'),
                          value: '${quiz.totalMarks}',
                        ),
                        _HeaderMetric(
                          label: context.tr('مدة', 'Duration'),
                          value: '${quiz.durationMinutes}m',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: context.tr('فتح المحرر', 'Open builder'),
                      variant: AppButtonVariant.secondary,
                      isExpanded: false,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizBuilderPage(
                            subjectId: subjectId,
                            initialQuiz: quiz,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionsTab extends StatelessWidget {
  const _SessionsTab({
    required this.subjectId,
    required this.lectures,
    required this.sections,
  });

  final String subjectId;
  final List<StaffSessionLink> lectures;
  final List<StaffSessionLink> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.tr('Lectures & Sections', 'Lectures & Sections'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            AppButton(
              label: context.tr('محاضرة', 'Lecture'),
              icon: Icons.add_rounded,
              isExpanded: false,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddLecturePage(subjectId: subjectId),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              label: context.tr('سكشن', 'Section'),
              variant: AppButtonVariant.secondary,
              isExpanded: false,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddSectionPage(subjectId: subjectId),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...lectures.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _SessionCard(session: item),
          ),
        ),
        ...sections.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _SessionCard(session: item),
          ),
        ),
      ],
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.subjectId, required this.events});

  final String subjectId;
  final List<StaffScheduleEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.tr('المواعيد المهمة', 'Important dates'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            AppButton(
              label: context.tr('إضافة Event', 'Add event'),
              icon: Icons.add_alarm_rounded,
              isExpanded: false,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScheduleEventPage(subjectId: subjectId),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...events.map(
          (event) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          'FF${event.colorHex.replaceAll('#', '')}',
                          radix: 16,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(event.description),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ScheduleEventPage(
                          subjectId: subjectId,
                          initialEvent: event,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final StaffSessionLink session;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(session.kind.name),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(session.description),
          const SizedBox(height: AppSpacing.sm),
          Text(
            session.mode == StaffSessionMode.online
                ? context.tr('Online session', 'Online session')
                : context.tr('Offline session', 'Offline session'),
          ),
          if (session.meetingLink != null || session.locationLabel != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(session.meetingLink ?? session.locationLabel ?? ''),
          ],
        ],
      ),
    );
  }
}
