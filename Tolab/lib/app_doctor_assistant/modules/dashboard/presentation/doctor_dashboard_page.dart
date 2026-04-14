import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/dashboard_models.dart';
import '../../../core/models/session_user.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../state/dashboard_view_model.dart';
import 'theme/app_spacing.dart';
import 'theme/dashboard_theme_tokens.dart';
import 'widgets/action_center_section.dart';
import 'widgets/course_health_section.dart';
import 'widgets/group_activity_feed_section.dart';
import 'widgets/notifications_preview_section.dart';
import 'widgets/pending_grading_center_section.dart';
import 'widgets/performance_analytics_section.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/risk_alerts_section.dart';
import 'widgets/smart_header_section.dart';
import 'widgets/smart_suggestions_section.dart';
import 'widgets/smart_timeline_section.dart';
import 'widgets/student_activity_insights_section.dart';
import 'widgets/students_attention_section.dart';
import 'widgets/subjects_overview_section.dart';
import 'widgets/today_focus_section.dart';
import 'widgets/weekly_summary_section.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({
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
      unreadNotifications: snapshot.notificationsPreview.unreadCount,
      child: Container(
        color: tokens.pageBackground,
        child: RefreshIndicator(
          onRefresh: () async {
            vm.load(force: true);
            await Future<void>.delayed(const Duration(milliseconds: 400));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(DashboardAppSpacing.xl),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final content = _DashboardContent(
                  snapshot: snapshot,
                  onToggleStyle: onToggleStyle,
                  onRefresh: () => vm.load(force: true),
                );

                if (constraints.maxWidth >= 1200) {
                  return content.desktop(context);
                }
                if (constraints.maxWidth >= 760) {
                  return content.tablet(context);
                }
                return content.mobile(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent {
  const _DashboardContent({
    required this.snapshot,
    required this.onToggleStyle,
    required this.onRefresh,
  });

  final DashboardSnapshot snapshot;
  final VoidCallback onToggleStyle;
  final VoidCallback onRefresh;

  void _open(BuildContext context, String route) {
    if (route.isEmpty) {
      return;
    }
    context.go(route);
  }

  Widget mobile(BuildContext context) {
    final items = _sections(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .expand((widget) => [widget, const SizedBox(height: DashboardAppSpacing.lg)])
          .toList()
        ..removeLast(),
    );
  }

  Widget tablet(BuildContext context) {
    final items = _sections(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        items[0],
        const SizedBox(height: DashboardAppSpacing.lg),
        items[1],
        const SizedBox(height: DashboardAppSpacing.lg),
        Wrap(
          spacing: DashboardAppSpacing.lg,
          runSpacing: DashboardAppSpacing.lg,
          children: items
              .skip(2)
              .map(
                (child) => SizedBox(
                  width: 420,
                  child: child,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget desktop(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmartHeaderSection(
          header: snapshot.header,
          onRefresh: onRefresh,
          onToggleStyle: onToggleStyle,
        ),
        const SizedBox(height: DashboardAppSpacing.lg),
        QuickActionsSection(
          actions: snapshot.quickActions,
          onOpenRoute: (route) => _open(context, route),
        ),
        const SizedBox(height: DashboardAppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  ActionCenterSection(
                    section: snapshot.actionCenter,
                    onOpenRoute: (route) => _open(context, route),
                  ),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  TodayFocusSection(
                    focus: snapshot.todayFocus,
                    onOpenRoute: (route) => _open(context, route),
                  ),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  SmartTimelineSection(
                    timeline: snapshot.timeline,
                    onOpenRoute: (route) => _open(context, route),
                  ),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  SubjectsOverviewSection(
                    section: snapshot.subjectsOverview,
                    onOpenRoute: (route) => _open(context, route),
                  ),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  GroupActivityFeedSection(
                    feed: snapshot.groupActivityFeed,
                    onOpenRoute: (route) => _open(context, route),
                  ),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  WeeklySummarySection(summary: snapshot.weeklySummary),
                ],
              ),
            ),
            const SizedBox(width: DashboardAppSpacing.lg),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  StudentsAttentionSection(
                    section: snapshot.studentsAttention,
                    onOpenRoute: (route) => _open(context, route),
                  ),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  StudentActivityInsightsSection(
                    insights: snapshot.studentActivityInsights,
                  ),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  CourseHealthSection(health: snapshot.courseHealth),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  NotificationsPreviewSection(
                    section: snapshot.notificationsPreview,
                    onOpenRoute: (route) => _open(context, route),
                  ),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  PendingGradingCenterSection(
                    section: snapshot.pendingGrading,
                    onOpenRoute: (route) => _open(context, route),
                  ),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  PerformanceAnalyticsSection(
                    analytics: snapshot.performanceAnalytics,
                  ),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  RiskAlertsSection(
                    alerts: snapshot.riskAlerts,
                    onOpenRoute: (route) => _open(context, route),
                  ),
                  const SizedBox(height: DashboardAppSpacing.lg),
                  SmartSuggestionsSection(
                    suggestions: snapshot.smartSuggestions,
                    onOpenRoute: (route) => _open(context, route),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _sections(BuildContext context) {
    return [
      SmartHeaderSection(
        header: snapshot.header,
        onRefresh: onRefresh,
        onToggleStyle: onToggleStyle,
      ),
      QuickActionsSection(
        actions: snapshot.quickActions,
        onOpenRoute: (route) => _open(context, route),
      ),
      ActionCenterSection(
        section: snapshot.actionCenter,
        onOpenRoute: (route) => _open(context, route),
      ),
      TodayFocusSection(
        focus: snapshot.todayFocus,
        onOpenRoute: (route) => _open(context, route),
      ),
      SmartTimelineSection(
        timeline: snapshot.timeline,
        onOpenRoute: (route) => _open(context, route),
      ),
      SubjectsOverviewSection(
        section: snapshot.subjectsOverview,
        onOpenRoute: (route) => _open(context, route),
      ),
      StudentsAttentionSection(
        section: snapshot.studentsAttention,
        onOpenRoute: (route) => _open(context, route),
      ),
      StudentActivityInsightsSection(insights: snapshot.studentActivityInsights),
      CourseHealthSection(health: snapshot.courseHealth),
      GroupActivityFeedSection(
        feed: snapshot.groupActivityFeed,
        onOpenRoute: (route) => _open(context, route),
      ),
      NotificationsPreviewSection(
        section: snapshot.notificationsPreview,
        onOpenRoute: (route) => _open(context, route),
      ),
      PendingGradingCenterSection(
        section: snapshot.pendingGrading,
        onOpenRoute: (route) => _open(context, route),
      ),
      PerformanceAnalyticsSection(analytics: snapshot.performanceAnalytics),
      RiskAlertsSection(
        alerts: snapshot.riskAlerts,
        onOpenRoute: (route) => _open(context, route),
      ),
      WeeklySummarySection(summary: snapshot.weeklySummary),
      SmartSuggestionsSection(
        suggestions: snapshot.smartSuggestions,
        onOpenRoute: (route) => _open(context, route),
      ),
    ];
  }
}
