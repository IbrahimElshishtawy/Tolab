import 'package:flutter/material.dart';

import '../../core/spacing/app_spacing.dart';
import '../../core/widgets/app_card.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.searchHint,
    this.onSearchChanged,
    this.leading = const [],
    this.trailing = const [],
    this.filters = const [],
    this.selectedFilter,
    this.onFilterSelected,
  });

  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget> leading;
  final List<Widget> trailing;
  final List<String> filters;
  final String? selectedFilter;
  final ValueChanged<String>? onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 1040;
          final searchField = TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: const Icon(Icons.tune_rounded),
            ),
          );

          return Column(
            children: [
              if (isCompact)
                Column(
                  children: [
                    searchField,
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [...leading, ...trailing],
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [...leading, ...trailing],
                    ),
                  ],
                ),
              if (filters.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final filter in filters)
                        ChoiceChip(
                          label: Text(filter),
                          selected: filter == selectedFilter,
                          onSelected: (_) => onFilterSelected?.call(filter),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
