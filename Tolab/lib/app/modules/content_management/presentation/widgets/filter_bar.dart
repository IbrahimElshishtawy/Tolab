import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/content_models.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.searchController,
    required this.filters,
    required this.subjects,
    required this.instructors,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onSubjectChanged,
    required this.onInstructorChanged,
    required this.onStatusChanged,
    required this.onClear,
  });

  final TextEditingController searchController;
  final ContentFilters filters;
  final List<ContentSubjectOption> subjects;
  final List<ContentInstructorOption> instructors;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ContentType?> onTypeChanged;
  final ValueChanged<String?> onSubjectChanged;
  final ValueChanged<String?> onInstructorChanged;
  final ValueChanged<ContentStatus?> onStatusChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search content, subject, instructor',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          _Dropdown<ContentType?>(
            value: filters.type,
            hint: 'Type',
            items: [
              const DropdownMenuItem<ContentType?>(
                value: null,
                child: Text('All types'),
              ),
              ...ContentType.values.map(
                (item) => DropdownMenuItem<ContentType?>(
                  value: item,
                  child: Text(item.label),
                ),
              ),
            ],
            onChanged: onTypeChanged,
          ),
          _Dropdown<String?>(
            value: filters.subjectId,
            hint: 'Subject',
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All subjects'),
              ),
              ...subjects.map(
                (item) => DropdownMenuItem<String?>(
                  value: item.id,
                  child: Text(item.displayLabel),
                ),
              ),
            ],
            onChanged: onSubjectChanged,
          ),
          _Dropdown<String?>(
            value: filters.instructorId,
            hint: 'Instructor',
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All instructors'),
              ),
              ...instructors.map(
                (item) => DropdownMenuItem<String?>(
                  value: item.id,
                  child: Text(item.name),
                ),
              ),
            ],
            onChanged: onInstructorChanged,
          ),
          _Dropdown<ContentStatus?>(
            value: filters.status,
            hint: 'Status',
            items: [
              const DropdownMenuItem<ContentStatus?>(
                value: null,
                child: Text('All statuses'),
              ),
              ...ContentStatus.values.map(
                (item) => DropdownMenuItem<ContentStatus?>(
                  value: item,
                  child: Text(item.label),
                ),
              ),
            ],
            onChanged: onStatusChanged,
          ),
          PremiumButton(
            label: 'Clear',
            icon: Icons.refresh_rounded,
            isSecondary: true,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: hint),
      ),
    );
  }
}
