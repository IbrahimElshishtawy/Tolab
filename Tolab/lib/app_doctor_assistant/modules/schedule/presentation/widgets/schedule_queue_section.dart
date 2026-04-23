import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/modules/schedule/models/schedule_models.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../models/schedule_workspace_models.dart';

class ScheduleQueueSection extends StatelessWidget {
  const ScheduleQueueSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emptyLabel,
    required this.items,
    required this.onOpenEvent,
  });

  final String title;
  final String subtitle;
  final String emptyLabel;
  final List<FacultyScheduleItem> items;
  final ValueChanged<FacultyScheduleItem> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    return DoctorAssistantPanel(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            Text(emptyLabel, style: Theme.of(context).textTheme.bodySmall)
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
                        meta: '${item.event.subject} - ${item.followUpLabel}',
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
      ),
    );
  }
}
