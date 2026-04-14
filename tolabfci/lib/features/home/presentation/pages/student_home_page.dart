import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../providers/home_providers.dart';
import '../widgets/academic_overview_card.dart';
import '../widgets/empty_states.dart';
import '../widgets/focus_panels_section.dart';
import '../widgets/loading_states.dart';
import '../widgets/notifications_preview_section.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/required_today_section.dart';
import '../widgets/student_home_header.dart';
import '../widgets/study_insights_section.dart';
import '../widgets/weekly_timeline.dart';

class StudentHomePage extends ConsumerWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(studentHomeViewModelProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: viewModelAsync.when(
          data: (viewModel) => LayoutBuilder(
            builder: (context, constraints) {
              final columnCount = constraints.maxWidth >= 900 ? 2 : 1;

              return ListView(
                children: [
                  StudentHomeHeader(
                    profile: viewModel.profile,
                    unreadCount: viewModel.unreadCount,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RequiredTodaySection(items: viewModel.requiredTodayItems),
                  const SizedBox(height: AppSpacing.lg),
                  QuickActionsSection(actions: viewModel.quickActions),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionGrid(
                    columnCount: columnCount,
                    children: [
                      WeeklyTimeline(groups: viewModel.timelineGroups),
                      FocusPanelsSection(
                        quizzes: viewModel.upcomingQuizzes,
                        tasks: viewModel.nearbyTasks,
                        dailyTip: viewModel.dailyTip,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionGrid(
                    columnCount: columnCount,
                    children: [
                      AcademicOverviewCard(
                        snapshot: viewModel.academicSnapshot,
                      ),
                      StudyInsightsSection(model: viewModel.studyInsights),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NotificationsPreviewSection(
                    items: viewModel.notificationsPreview,
                    unreadCount: viewModel.unreadCount,
                  ),
                ],
              );
            },
          ),
          loading: () => const StudentHomeLoadingState(),
          error: (error, _) => StudentHomeErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(homeDashboardProvider),
          ),
        ),
      ),
    );
  }
}

class _SectionGrid extends StatelessWidget {
  const _SectionGrid({required this.columnCount, required this.children});

  final int columnCount;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (columnCount == 1) {
      return Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              const SizedBox(height: AppSpacing.lg),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = context.isDesktop ? AppSpacing.xl : AppSpacing.lg;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
