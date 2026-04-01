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
    final activeFilters = _activeFilterLabels(filters, lookups);
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: AppSpacing.md,
            spacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academic scope filters',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Refine the timetable by department, year, subject, instructor, section, event category, and delivery status.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
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
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _QuickCountChip(
                label: '${lookups.departments.length} departments',
                accent: AppColors.primary,
              ),
              _QuickCountChip(
                label: '${lookups.subjects.length} subjects',
                accent: AppColors.info,
              ),
              _QuickCountChip(
                label: '${lookups.sections.length} sections',
                accent: AppColors.secondary,
              ),
              _QuickCountChip(
                label: '${lookups.instructors.length} instructors',
                accent: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Current academic scope',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (activeFilters.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                'All departments, years, subjects, instructors, and sections are currently visible.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: activeFilters
                  .map((label) => _ActiveFilterChip(label: label))
                  .toList(growable: false),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Academic hierarchy',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
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
          Text(
            'Event categories',
            style: Theme.of(context).textTheme.titleSmall,
          ),
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
          Text(
            'Delivery status and conflict review',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _ToggleTile(
                title: 'Planned',
                subtitle: 'Future and active items',
                icon: Icons.pending_actions_rounded,
                value: filters.showPlanned,
                accent: AppColors.primary,
                onChanged: (value) =>
                    onChanged(filters.copyWith(showPlanned: value)),
              ),
              _ToggleTile(
                title: 'Completed',
                subtitle: 'Finished sessions',
                icon: Icons.task_alt_rounded,
                value: filters.showCompleted,
                accent: AppColors.secondary,
                onChanged: (value) =>
                    onChanged(filters.copyWith(showCompleted: value)),
              ),
              _ToggleTile(
                title: 'Conflicts only',
                subtitle: 'Show clashes first',
                icon: Icons.warning_amber_rounded,
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
    required this.icon,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
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

class _QuickCountChip extends StatelessWidget {
  const _QuickCountChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

List<String> _activeFilterLabels(
  ScheduleFilters filters,
  ScheduleLookupBundle lookups,
) {
  final labels = <String>[];
  _addLookupLabel(
    labels,
    'Department',
    filters.departmentId,
    lookups.departments,
  );
  _addLookupLabel(labels, 'Year', filters.yearId, lookups.years);
  _addLookupLabel(labels, 'Subject', filters.subjectId, lookups.subjects);
  _addLookupLabel(
    labels,
    'Instructor',
    filters.instructorId,
    lookups.instructors,
  );
  _addLookupLabel(labels, 'Section', filters.sectionId, lookups.sections);
  if (filters.conflictsOnly) {
    labels.add('Conflicts only');
  }
  if (!filters.showPlanned) {
    labels.add('Completed only');
  }
  if (!filters.showCompleted) {
    labels.add('Planned only');
  }
  if (filters.eventTypes.length != ScheduleEventType.values.length) {
    labels.add(filters.eventTypes.map((type) => type.label).join(' / '));
  }
  return labels;
}

void _addLookupLabel(
  List<String> labels,
  String prefix,
  String? value,
  List<ScheduleOption> items,
) {
  if (value == null) return;
  ScheduleOption? match;
  for (final item in items) {
    if (item.id == value) {
      match = item;
      break;
    }
  }
  labels.add('$prefix: ${match?.label ?? value}');
}
