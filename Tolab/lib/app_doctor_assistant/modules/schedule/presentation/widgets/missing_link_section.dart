import 'package:flutter/material.dart';

import '../models/schedule_workspace_models.dart';
import 'schedule_queue_section.dart';

class MissingLinkSection extends StatelessWidget {
  const MissingLinkSection({
    super.key,
    required this.items,
    required this.onOpenEvent,
  });

  final List<FacultyScheduleItem> items;
  final ValueChanged<FacultyScheduleItem> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    return ScheduleQueueSection(
      title: 'Missing room / link',
      subtitle:
          'Sessions still missing a confirmed room, hall, or online meeting link.',
      emptyLabel: 'Every listed session already has room and link details.',
      items: items.take(4).toList(growable: false),
      onOpenEvent: onOpenEvent,
    );
  }
}
