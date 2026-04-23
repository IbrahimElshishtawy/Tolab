import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../models/schedule_workspace_models.dart';

class ScheduleControlsPanel extends StatelessWidget {
  const ScheduleControlsPanel({
    super.key,
    required this.activeFilters,
    required this.onToggleFilter,
    required this.onAddLecture,
    required this.onAddSection,
    required this.onAddQuiz,
    required this.onAddTask,
  });

  final Set<FacultyScheduleFilter> activeFilters;
  final ValueChanged<FacultyScheduleFilter> onToggleFilter;
  final VoidCallback onAddLecture;
  final VoidCallback onAddSection;
  final VoidCallback onAddQuiz;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Schedule controls', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Filter the calendar by academic activity type and jump directly into high-frequency create flows.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: FacultyScheduleFilter.values
                .map(
                  (filter) => FilterChip(
                    label: Text(filter.label),
                    avatar: Icon(filter.icon, size: 16),
                    selected: activeFilters.contains(filter),
                    onSelected: (_) => onToggleFilter(filter),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.tonalIcon(
                onPressed: onAddLecture,
                icon: const Icon(Icons.slideshow_rounded),
                label: const Text('Add Lecture'),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddSection,
                icon: const Icon(Icons.widgets_rounded),
                label: const Text('Add Section'),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddQuiz,
                icon: const Icon(Icons.quiz_rounded),
                label: const Text('Add Quiz'),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddTask,
                icon: const Icon(Icons.task_alt_rounded),
                label: const Text('Add Task'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
