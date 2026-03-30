import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../state/models/moderation_state_models.dart';

class ModerationTableColumn<T> {
  const ModerationTableColumn({
    required this.key,
    required this.label,
    required this.cellBuilder,
    this.size = ColumnSize.M,
    this.sortable = false,
  });

  final String key;
  final String label;
  final Widget Function(BuildContext context, T item) cellBuilder;
  final ColumnSize size;
  final bool sortable;
}

class ModerationTableCard<T> extends StatelessWidget {
  const ModerationTableCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.columns,
    required this.idOf,
    required this.mobileTitleBuilder,
    required this.mobileSubtitleBuilder,
    required this.pageSlice,
    required this.selectedIds,
    required this.sortKey,
    required this.ascending,
    this.headerTrailing,
    this.mobileBadgesBuilder,
    this.mobileFooterBuilder,
    this.onToggleSelection,
    this.onToggleVisibleSelection,
    this.onSort,
    this.onRowTap,
    this.onPageChanged,
    this.emptyTitle = 'No matching records',
    this.emptySubtitle = 'Try widening your filters or search query.',
  });

  final String title;
  final String subtitle;
  final List<T> items;
  final List<ModerationTableColumn<T>> columns;
  final String Function(T item) idOf;
  final String Function(T item) mobileTitleBuilder;
  final String Function(T item) mobileSubtitleBuilder;
  final List<Widget> Function(BuildContext context, T item)? mobileBadgesBuilder;
  final List<Widget> Function(BuildContext context, T item)? mobileFooterBuilder;
  final ModerationPageSlice<T> pageSlice;
  final Set<String> selectedIds;
  final String sortKey;
  final bool ascending;
  final Widget? headerTrailing;
  final void Function(String itemId, bool selected)? onToggleSelection;
  final void Function(bool selected)? onToggleVisibleSelection;
  final void Function(String columnKey)? onSort;
  final void Function(T item)? onRowTap;
  final ValueChanged<int>? onPageChanged;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    final allVisibleSelected =
        pageSlice.visibleIds.isNotEmpty &&
        pageSlice.visibleIds.every(selectedIds.contains);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (headerTrailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                Flexible(child: headerTrailing!),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (items.isEmpty) {
                  return _EmptyState(title: emptyTitle, subtitle: emptySubtitle);
                }

                if (constraints.maxWidth < 920) {
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final itemId = idOf(item);
                      final selected = selectedIds.contains(itemId);
                      return AppCard(
                        interactive: true,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        onTap: onRowTap == null ? null : () => onRowTap!(item),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (onToggleSelection != null)
                                  Checkbox(
                                    value: selected,
                                    onChanged: (value) => onToggleSelection!(
                                      itemId,
                                      value ?? false,
                                    ),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mobileTitleBuilder(item),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        mobileSubtitleBuilder(item),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                            if (mobileBadgesBuilder != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: mobileBadgesBuilder!(context, item),
                              ),
                            ],
                            if (mobileFooterBuilder != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: mobileFooterBuilder!(context, item),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }

                final sortedColumnIndex = columns.indexWhere(
                  (column) => column.key == sortKey,
                );

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable2(
                      showCheckboxColumn: false,
                      columnSpacing: 18,
                      horizontalMargin: 8,
                      minWidth: columns.length * 170,
                      sortColumnIndex: sortedColumnIndex >= 0
                          ? sortedColumnIndex + 1
                          : null,
                      sortAscending: ascending,
                      columns: [
                        DataColumn2(
                          fixedWidth: 52,
                          label: Checkbox(
                            value: allVisibleSelected,
                            onChanged: onToggleVisibleSelection == null
                                ? null
                                : (value) =>
                                      onToggleVisibleSelection!(value ?? false),
                          ),
                        ),
                        for (final column in columns)
                          DataColumn2(
                            size: column.size,
                            onSort: column.sortable && onSort != null
                                ? (columnIndex, ascending) => onSort!(column.key)
                                : null,
                            label: Text(column.label),
                          ),
                      ],
                      rows: [
                        for (final item in items)
                          DataRow2(
                            onTap: onRowTap == null ? null : () => onRowTap!(item),
                            color: WidgetStateProperty.resolveWith((states) {
                              final selected = selectedIds.contains(idOf(item));
                              if (selected) {
                                return AppColors.primary.withValues(alpha: 0.08);
                              }
                              if (states.contains(WidgetState.hovered)) {
                                return AppColors.primary.withValues(alpha: 0.04);
                              }
                              return Colors.transparent;
                            }),
                            cells: [
                              DataCell(
                                Checkbox(
                                  value: selectedIds.contains(idOf(item)),
                                  onChanged: onToggleSelection == null
                                      ? null
                                      : (value) => onToggleSelection!(
                                            idOf(item),
                                            value ?? false,
                                          ),
                                ),
                              ),
                              for (final column in columns)
                                DataCell(column.cellBuilder(context, item)),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _PaginationBar(
            totalItems: pageSlice.totalItems,
            page: pageSlice.page,
            totalPages: pageSlice.totalPages,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.totalItems,
    required this.page,
    required this.totalPages,
    this.onPageChanged,
  });

  final int totalItems;
  final int page;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final summary =
            '$totalItems items  •  Page $page of $totalPages';

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _PagerButton(
                    label: 'Previous',
                    enabled: page > 1,
                    onPressed: onPageChanged == null
                        ? null
                        : () => onPageChanged!(page - 1),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _PagerButton(
                    label: 'Next',
                    enabled: page < totalPages,
                    onPressed: onPageChanged == null
                        ? null
                        : () => onPageChanged!(page + 1),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Text(summary, style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            _PagerButton(
              label: 'Previous',
              enabled: page > 1,
              onPressed: onPageChanged == null
                  ? null
                  : () => onPageChanged!(page - 1),
            ),
            const SizedBox(width: AppSpacing.sm),
            _PagerButton(
              label: 'Next',
              enabled: page < totalPages,
              onPressed: onPageChanged == null
                  ? null
                  : () => onPageChanged!(page + 1),
            ),
          ],
        );
      },
    );
  }
}

class _PagerButton extends StatelessWidget {
  const _PagerButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: AppMotion.fast,
      opacity: enabled ? 1 : 0.45,
      child: FilledButton.tonal(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
            child: const Icon(Icons.inbox_outlined, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
