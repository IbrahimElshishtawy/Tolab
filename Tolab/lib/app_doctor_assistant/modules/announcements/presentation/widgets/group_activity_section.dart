import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../models/announcements_workspace_models.dart';

class GroupActivitySection extends StatelessWidget {
  const GroupActivitySection({
    super.key,
    required this.activity,
    required this.unresolvedThreads,
    required this.studentQuestions,
  });

  final List<AnnouncementActivityItem> activity;
  final List<AnnouncementActivityItem> unresolvedThreads;
  final List<AnnouncementActivityItem> studentQuestions;

  @override
  Widget build(BuildContext context) {
    return DoctorAssistantPanel(
      title: context.l10n.byValue('Group activity panel'),
      subtitle: context.l10n.byValue(
          'Latest posts, fresh comments, unresolved threads, and the newest student questions in one place.'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActivityGroup(title: 'Latest activity', items: activity),
          const SizedBox(height: AppSpacing.md),
          _ActivityGroup(title: 'Unresolved threads', items: unresolvedThreads),
          const SizedBox(height: AppSpacing.md),
          _ActivityGroup(title: 'Latest student questions', items: studentQuestions),
        ],
      ),
    );
  }
}

class _ActivityGroup extends StatelessWidget {
  const _ActivityGroup({required this.title, required this.items});

  final String title;
  final List<AnnouncementActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.byValue(title), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (items.isEmpty)
          Text(
            context.l10n.byValue('No items in this queue yet.'),
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: DoctorAssistantItemCard(
                      icon: item.icon,
                      title: item.title,
                      subtitle: item.timestampLabel,
                      meta: item.subtitle,
                      statusLabel: 'Live',
                      highlightColor: item.color,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }
}
