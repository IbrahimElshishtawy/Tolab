import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../providers/home_providers.dart';
import '../widgets/academic_info_card.dart';
import '../widgets/date_selector_section.dart';
import '../widgets/home_header.dart';
import '../widgets/upcoming_lectures_section.dart';
import '../widgets/upcoming_quizzes_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: dashboardAsync.when(
          data: (dashboard) {
            final crossAxisCount = context.isDesktop ? 2 : 1;
            return ListView(
              children: [
                HomeHeader(dashboard: dashboard, unreadCount: unreadCount),
                const SizedBox(height: AppSpacing.lg),
                GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: context.isDesktop ? 1.8 : 1.25,
                  children: [
                    const DateSelectorSection(),
                    AcademicInfoCard(profile: dashboard.profile),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                UpcomingLecturesSection(lectures: dashboard.upcomingLectures),
                const SizedBox(height: AppSpacing.lg),
                UpcomingQuizzesSection(quizzes: dashboard.upcomingQuizzes),
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'Loading dashboard...'),
          error: (error, stackTrace) => ErrorStateWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(homeDashboardProvider),
          ),
        ),
      ),
    );
  }
}

