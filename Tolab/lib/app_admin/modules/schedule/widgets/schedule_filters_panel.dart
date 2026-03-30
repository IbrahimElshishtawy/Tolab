import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/forms/app_dropdown_field.dart';
import '../../../shared/widgets/premium_button.dart';
import '../models/schedule_models.dart';

// Global filters that drive calendar visibility and conflict inspection.
class ScheduleFiltersPanel extends StatelessWidget {
  const ScheduleFiltersPanel({
    super.key,
    required this.filters,
    required this.lookups,
    required this.onChanged,
    required this.onReset,
  });

  final ScheduleFilters filters;
  final ScheduleLookupBundle lookups;
  final ValueChanged<ScheduleFilters> onChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 860;
    final dropdowns = <Widget>[
      _FilterDropdown(
        label: 'Department',
        value: filters.departmentId,
        items: lookups.departments,
        onChanged: (value) => onChanged(
          filters.copyWith(departmentId: value, clearDepartment: value == null),
        ),
      ),
      _FilterDropdown(
        label: 'Year',
        value: filters.yearId,
        items: lookups.years,
        onChanged: (value) => onChanged(
          filters.copyWith(yearId: value, clearYear: value == null),
        ),
      ),
      _FilterDropdown(
        label: 'Subject',
        value: filters.subjectId,
        items: lookups.subjects,
        onChanged: (value) => onChanged(
          filters.copyWith(subjectId: value, clearSubject: value == null),
        ),
      ),
      _FilterDropdown(
        label: 'Instructor',
        value: filters.instructorId,
        items: lookups.instructors,
        onChanged: (value) => onChanged(
          filters.copyWith(instructorId: value, clearInstructor: value == null),
        ),
      ),
      _FilterDropdown(
        label: 'Section',
        value: filters.sectionId,
        items: lookups.sections,
        onChanged: (value) => onChanged(
          filters.copyWith(sectionId: value, clearSection: value == null),
        ),
      ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule filters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Shape the calendar by department, year, subject, instructor, state, and conflicts.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PremiumButton(
                label: 'Reset',
                icon: Icons.restart_alt_rounded,
                isSecondary: true,
                onPressed: onReset,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isNarrow)
            Column(
              children: [
                for (final widget in dropdowns) ...[
                  widget,
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            )
          else
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: dropdowns
                  .map((widget) => SizedBox(width: 220, child: widget))
                  .toList(growable: false),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text('Event types', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: ScheduleEventType.values
                .map((type) {
                  final selected = filters.eventTypes.contains(type);
                  return FilterChip(
                    selected: selected,
                    label: Text(type.label),
                    avatar: Icon(type.icon, size: 16, color: type.color),
                    onSelected: (_) {
                      final next = <ScheduleEventType>{...filters.eventTypes};
                      if (selected) {
                        next.remove(type);
                      } else {
                        next.add(type);
                      }
                      onChanged(filters.copyWith(eventTypes: next));
                    },
                  );
                })
                .toList(growable: false),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _ToggleTile(
                title: 'Planned',
                subtitle: 'Future and active items',
                value: filters.showPlanned,
                accent: AppColors.primary,
                onChanged: (value) =>
                    onChanged(filters.copyWith(showPlanned: value)),
              ),
              _ToggleTile(
                title: 'Completed',
                subtitle: 'Finished sessions',
                value: filters.showCompleted,
                accent: AppColors.secondary,
                onChanged: (value) =>
                    onChanged(filters.copyWith(showCompleted: value)),
              ),
              _ToggleTile(
                title: 'Conflicts only',
                subtitle: 'Show clashes first',
                value: filters.conflictsOnly,
                accent: AppColors.danger,
                onChanged: (value) =>
                    onChanged(filters.copyWith(conflictsOnly: value)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<ScheduleOption> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppDropdownField<String>(
      label: label,
      value: value,
      onChanged: onChanged,
      items: items
          .map(
            (item) => AppDropdownItem<String>(
              value: item.id,
              label: item.subtitle == null
                  ? item.label
                  : '${item.label} • ${item.subtitle}',
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(
          color: value
              ? accent.withValues(alpha: 0.6)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
