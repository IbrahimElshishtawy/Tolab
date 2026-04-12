import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/session_user.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../state/dashboard_view_model.dart';
import 'theme/app_spacing.dart';
import 'theme/dashboard_theme_tokens.dart';
import 'widgets/action_required_section.dart';
import 'widgets/doctor_home_header.dart';
import 'widgets/group_activity_section.dart';
import 'widgets/notifications_preview_section.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/student_insights_section.dart';
import 'widgets/subjects_overview_section.dart';
import 'widgets/today_schedule_section.dart';
import 'widgets/today_stats_section.dart';
import 'widgets/upcoming_section.dart';

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({
    super.key,
    required this.user,
    required this.vm,
    required this.onToggleStyle,
  });

  final SessionUser user;
  final DashboardViewModel vm;
  final VoidCallback onToggleStyle;

  @override
  Widget build(BuildContext context) {
    final snapshot = vm.snapshot!;
    final tokens = DashboardThemeTokens.of(context);

    return DoctorAssistantShell(
      user: user,
      activeRoute: '/workspace/home',
      unreadNotifications: snapshot.notifications.unreadCount,
      child: Container(
        color: tokens.pageBackground,
        child: RefreshIndicator(
          onRefresh: () async {
            vm.load(force: true);
            await Future<void>.delayed(const Duration(milliseconds: 400));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: DashboardAppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorHomeHeader(
                  user: snapshot.user,
                  unreadNotifications: snapshot.notifications.unreadCount,
                  onRefresh: () => vm.load(force: true),
                  onToggleStyle: onToggleStyle,
                ),
                const SizedBox(height: DashboardAppSpacing.xl),
                QuickActionsSection(
                  actions: snapshot.quickActions,
                  onOpenRoute: (route) => context.go(route),
                ),
                const SizedBox(height: DashboardAppSpacing.xl),
                TodayStatsSection(
                  stats: snapshot.todayStats,
                  onOpenRoute: (route) => context.go(route),
                ),
                const SizedBox(height: DashboardAppSpacing.xl),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 1100) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                ActionRequiredSection(
                                  items: snapshot.actionRequired,
                                  onOpenRoute: (route) => context.go(route),
                                ),
                                const SizedBox(height: DashboardAppSpacing.xl),
                                TodayScheduleSection(
                                  items: snapshot.todaySchedule,
                                  onOpenRoute: (route) => context.go(route),
                                ),
                                const SizedBox(height: DashboardAppSpacing.xl),
                                SubjectsOverviewSection(
                                  subjects: snapshot.subjectsPreview,
                                  onOpenRoute: (route) => context.go(route),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: DashboardAppSpacing.xl),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                UpcomingSection(
                                  items: snapshot.upcoming,
                                  onOpenRoute: (route) => context.go(route),
                                ),
                                const SizedBox(height: DashboardAppSpacing.xl),
                                NotificationsPreviewSection(
                                  notifications: snapshot.notifications,
                                  onOpenRoute: (route) => context.go(route),
                                ),
                                const SizedBox(height: DashboardAppSpacing.xl),
                                StudentInsightsSection(
                                  insights: snapshot.studentInsights,
                                ),
                                const SizedBox(height: DashboardAppSpacing.xl),
                                GroupActivitySection(
                                  items: snapshot.groupActivity,
                                  onOpenRoute: (route) => context.go(route),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        ActionRequiredSection(
                          items: snapshot.actionRequired,
                          onOpenRoute: (route) => context.go(route),
                        ),
                        const SizedBox(height: DashboardAppSpacing.xl),
                        TodayScheduleSection(
                          items: snapshot.todaySchedule,
                          onOpenRoute: (route) => context.go(route),
                        ),
                        const SizedBox(height: DashboardAppSpacing.xl),
                        UpcomingSection(
                          items: snapshot.upcoming,
                          onOpenRoute: (route) => context.go(route),
                        ),
                        const SizedBox(height: DashboardAppSpacing.xl),
                        SubjectsOverviewSection(
                          subjects: snapshot.subjectsPreview,
                          onOpenRoute: (route) => context.go(route),
                        ),
                        const SizedBox(height: DashboardAppSpacing.xl),
                        GroupActivitySection(
                          items: snapshot.groupActivity,
                          onOpenRoute: (route) => context.go(route),
                        ),
                        const SizedBox(height: DashboardAppSpacing.xl),
                        StudentInsightsSection(
                          insights: snapshot.studentInsights,
                        ),
                        const SizedBox(height: DashboardAppSpacing.xl),
                        NotificationsPreviewSection(
                          notifications: snapshot.notifications,
                          onOpenRoute: (route) => context.go(route),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
