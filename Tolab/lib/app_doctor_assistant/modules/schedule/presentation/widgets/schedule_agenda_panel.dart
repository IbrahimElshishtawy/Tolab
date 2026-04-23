import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/modules/schedule/models/schedule_models.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../models/schedule_workspace_models.dart';

class ScheduleAgendaPanel extends StatelessWidget {
  const ScheduleAgendaPanel({
    super.key,
    required this.upcoming,
    required this.needsFollowUp,
    required this.missingContext,
    required this.onOpenEvent,
  });

  final List<FacultyScheduleItem> upcoming;
  final List<FacultyScheduleItem> needsFollowUp;
  final List<FacultyScheduleItem> missingContext;
  final ValueChanged<FacultyScheduleItem> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    return DoctorAssistantPanel(
      title: 'Upcoming agenda',
      subtitle:
          'This week, items needing follow-up, and sessions still missing a room or meeting link.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AgendaGroup(
            title: 'This week',
            items: upcoming.take(4).toList(growable: false),
            onOpenEvent: onOpenEvent,
          ),
          const SizedBox(height: AppSpacing.md),
          _AgendaGroup(
            title: 'Needs follow-up',
            items: needsFollowUp.take(4).toList(growable: false),
            onOpenEvent: onOpenEvent,
          ),
          const SizedBox(height: AppSpacing.md),
          _AgendaGroup(
            title: 'Missing room / link',
            items: missingContext.take(4).toList(growable: false),
            onOpenEvent: onOpenEvent,
          ),
        ],
      ),
    );
  }
}

class _AgendaGroup extends StatelessWidget {
  const _AgendaGroup({
    required this.title,
    required this.items,
    required this.onOpenEvent,
  });

  final String title;
  final List<FacultyScheduleItem> items;
  final ValueChanged<FacultyScheduleItem> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (items.isEmpty)
          Text('No events in this queue.', style: Theme.of(context).textTheme.bodySmall)
        else
          Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: DoctorAssistantItemCard(
                      icon: item.filter.icon,
                      title: item.event.title,
                      subtitle: scheduleDateLabel(item.event.startAt),
                      meta: '${item.event.subject} • ${item.followUpLabel}',
                      statusLabel: item.statusLabel,
                      highlightColor: item.hasConflict
                          ? const Color(0xFFDC2626)
                          : item.isMissingContext
                          ? const Color(0xFFF59E0B)
                          : item.event.type.color,
                      onTap: () => onOpenEvent(item),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }
}
