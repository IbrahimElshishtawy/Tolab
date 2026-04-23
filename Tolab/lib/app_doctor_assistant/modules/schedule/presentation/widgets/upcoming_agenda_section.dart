import 'package:flutter/material.dart';

import '../models/schedule_workspace_models.dart';
import 'schedule_queue_section.dart';

class UpcomingAgendaSection extends StatelessWidget {
  const UpcomingAgendaSection({
    super.key,
    required this.items,
    required this.onOpenEvent,
  });

  final List<FacultyScheduleItem> items;
  final ValueChanged<FacultyScheduleItem> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    return ScheduleQueueSection(
      title: 'Upcoming agenda',
      subtitle:
          'The next scheduled teaching items for the current planning window.',
      emptyLabel: 'No upcoming events in the selected window.',
      items: items.take(4).toList(growable: false),
      onOpenEvent: onOpenEvent,
    );
  }
}
