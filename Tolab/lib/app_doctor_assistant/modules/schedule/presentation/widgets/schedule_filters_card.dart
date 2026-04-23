import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../models/schedule_workspace_models.dart';

class ScheduleFiltersCard extends StatelessWidget {
  const ScheduleFiltersCard({
    super.key,
    required this.activeFilters,
    required this.onToggleFilter,
  });

  final Set<FacultyScheduleFilter> activeFilters;
  final ValueChanged<FacultyScheduleFilter> onToggleFilter;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule filters',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Focus the planner by activity type without repeating creation buttons again below.',
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
        ],
      ),
    );
  }
}
