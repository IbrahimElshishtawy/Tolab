import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/content_models.dart';
import 'status_badge.dart';

class AdminTable extends StatelessWidget {
  const AdminTable({
    super.key,
    required this.items,
    required this.selectedIds,
    required this.areAllSelected,
    required this.sort,
    required this.currentPage,
    required this.totalPages,
    required this.onRowSelected,
    required this.onSelectAll,
    required this.onSortChanged,
    required this.onPageChanged,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ContentRecord> items;
  final Set<String> selectedIds;
  final bool areAllSelected;
  final ContentSort sort;
  final int currentPage;
  final int totalPages;
  final void Function(String id, bool selected) onRowSelected;
  final ValueChanged<bool> onSelectAll;
  final ValueChanged<ContentSortField> onSortChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ContentRecord> onView;
  final ValueChanged<ContentRecord> onEdit;
  final ValueChanged<ContentRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isMobile(context)) {
      return AnimationLimiter(
        child: Column(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 320),
                child: SlideAnimation(
                  verticalOffset: 24,
                  child: FadeInAnimation(
                    child: _MobileCard(
                      item: items[index],
                      selected: selectedIds.contains(items[index].id),
                      onSelected: (value) =>
                          onRowSelected(items[index].id, value),
                      onView: () => onView(items[index]),
                      onEdit: () => onEdit(items[index]),
                      onDelete: () => onDelete(items[index]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _PaginationFooter(
              currentPage: currentPage,
              totalPages: totalPages,
              onPageChanged: onPageChanged,
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: areAllSelected,
                onChanged: (value) => onSelectAll(value ?? false),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Bulk select',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          DataTable2(
            minWidth: 980,
            columnSpacing: 18,
            horizontalMargin: 12,
            headingRowHeight: 52,
            dataRowHeight: 78,
            columns: [
              const DataColumn2(label: SizedBox.shrink(), fixedWidth: 46),
              _sortColumn('Title', ContentSortField.title, onSortChanged),
              const DataColumn2(label: Text('Type'), size: ColumnSize.S),
              const DataColumn2(label: Text('Subject'), size: ColumnSize.L),
              const DataColumn2(label: Text('Instructor')),
              const DataColumn2(label: Text('Status'), size: ColumnSize.S),
              _sortColumn(
                'Publish date',
                ContentSortField.publishDate,
                onSortChanged,
              ),
              const DataColumn2(label: Text('Actions'), fixedWidth: 190),
            ],
            rows: [
              for (final item in items)
                DataRow2(
                  selected: selectedIds.contains(item.id),
                  onTap: () => onView(item),
                  cells: [
                    DataCell(
                      Checkbox(
                        value: selectedIds.contains(item.id),
                        onChanged: (value) =>
                            onRowSelected(item.id, value ?? false),
                      ),
                    ),
                    DataCell(_TitleCell(item: item)),
                    DataCell(Text(item.type.label)),
                    DataCell(Text(item.subject.displayLabel)),
                    DataCell(Text(item.instructor.name)),
                    DataCell(StatusBadge(status: item.status)),
                    DataCell(Text(item.publishDateLabel)),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Preview',
                            onPressed: () => onView(item),
                            icon: const Icon(
                              Icons.visibility_rounded,
                              size: 18,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => onEdit(item),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () => onDelete(item),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PaginationFooter(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }

  DataColumn2 _sortColumn(
    String label,
    ContentSortField field,
    ValueChanged<ContentSortField> onPressed,
  ) {
    return DataColumn2(
      label: InkWell(
        onTap: () => onPressed(field),
        child: Row(
          children: [
            Text(label),
            const SizedBox(width: 6),
            Icon(
              sort.field == field && sort.ascending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleCell extends StatelessWidget {
  const _TitleCell({required this.item});

  final ContentRecord item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(item.type.icon, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${item.submittedCount}/${item.enrollmentCount} submissions • ${item.attachments.length} files',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MobileCard extends StatelessWidget {
  const _MobileCard({
    required this.item,
    required this.selected,
    required this.onSelected,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final ContentRecord item;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      interactive: true,
      onTap: onView,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (value) => onSelected(value ?? false),
              ),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.subject.displayLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('${item.type.label} • ${item.instructor.name}'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _CompactChip(label: item.publishDateLabel),
              _CompactChip(label: item.dueDateLabel),
              _CompactChip(label: '${item.pendingCount} pending'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              PremiumButton(
                label: 'Preview',
                icon: Icons.visibility_rounded,
                isSecondary: true,
                onPressed: onView,
              ),
              PremiumButton(
                label: 'Edit',
                icon: Icons.edit_rounded,
                isSecondary: true,
                onPressed: onEdit,
              ),
              PremiumButton(
                label: 'Delete',
                icon: Icons.delete_outline_rounded,
                isDestructive: true,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactChip extends StatelessWidget {
  const _CompactChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Page $currentPage of $totalPages',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        IconButton(
          onPressed: currentPage <= 1
              ? null
              : () => onPageChanged(currentPage - 1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        IconButton(
          onPressed: currentPage >= totalPages
              ? null
              : () => onPageChanged(currentPage + 1),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
