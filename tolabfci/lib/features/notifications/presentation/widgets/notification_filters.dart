import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_spacing.dart';

class NotificationFilters extends StatelessWidget {
  const NotificationFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final filters = {
      'all': context.tr('الكل', 'All'),
      'unread': context.tr('غير المقروءة', 'Unread'),
      'important': context.tr('الهامة', 'Important'),
    };

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final entry in filters.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: selectedFilter == entry.key,
            onSelected: (_) => onFilterSelected(entry.key),
          ),
      ],
    );
  }
}
