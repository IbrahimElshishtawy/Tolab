import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../models/schedule_workspace_models.dart';
import 'follow_up_section.dart';
import 'missing_link_section.dart';
import 'quick_actions_card.dart';
import 'schedule_filters_card.dart';
import 'upcoming_agenda_section.dart';

class ScheduleMobileLayout extends StatelessWidget {
  const ScheduleMobileLayout({
    super.key,
    required this.quickActions,
    required this.activeFilters,
    required this.onToggleFilter,
    required this.upcoming,
    required this.needsFollowUp,
    required this.missingContext,
    required this.onOpenEvent,
    required this.board,
  });

  final List<QuickActionItem> quickActions;
  final Set<FacultyScheduleFilter> activeFilters;
  final ValueChanged<FacultyScheduleFilter> onToggleFilter;
  final List<FacultyScheduleItem> upcoming;
  final List<FacultyScheduleItem> needsFollowUp;
  final List<FacultyScheduleItem> missingContext;
  final ValueChanged<FacultyScheduleItem> onOpenEvent;
  final Widget board;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuickActionsCard(actions: quickActions),
        const SizedBox(height: AppSpacing.md),
        ScheduleFiltersCard(
          activeFilters: activeFilters,
          onToggleFilter: onToggleFilter,
        ),
        const SizedBox(height: AppSpacing.md),
        UpcomingAgendaSection(items: upcoming, onOpenEvent: onOpenEvent),
        const SizedBox(height: AppSpacing.md),
        FollowUpSection(items: needsFollowUp, onOpenEvent: onOpenEvent),
        const SizedBox(height: AppSpacing.md),
        MissingLinkSection(items: missingContext, onOpenEvent: onOpenEvent),
        const SizedBox(height: AppSpacing.md),
        board,
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
