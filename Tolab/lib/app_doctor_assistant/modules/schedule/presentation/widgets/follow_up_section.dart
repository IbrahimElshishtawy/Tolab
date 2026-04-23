import 'package:flutter/material.dart';

import '../models/schedule_workspace_models.dart';
import 'schedule_queue_section.dart';

class FollowUpSection extends StatelessWidget {
  const FollowUpSection({
    super.key,
    required this.items,
    required this.onOpenEvent,
  });

  final List<FacultyScheduleItem> items;
  final ValueChanged<FacultyScheduleItem> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    return ScheduleQueueSection(
      title: 'Needs follow-up',
      subtitle:
          'Conflicts, pending confirmations, and sessions that still need manual review.',
      emptyLabel: 'Nothing needs follow-up right now.',
      items: items.take(4).toList(growable: false),
      onOpenEvent: onOpenEvent,
    );
  }
}
