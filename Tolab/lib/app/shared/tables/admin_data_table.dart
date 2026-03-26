import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/spacing/app_spacing.dart';
import '../../core/widgets/app_card.dart';

class AdminTableColumn<T> {
  const AdminTableColumn({
    required this.label,
    required this.cellBuilder,
    this.size = ColumnSize.M,
  });

  final String label;
  final Widget Function(T item) cellBuilder;
  final ColumnSize size;
}

class AdminDataTable<T> extends StatelessWidget {
  const AdminDataTable({super.key, required this.items, required this.columns});

  final List<T> items;
  final List<AdminTableColumn<T>> columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = items[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 360),
                child: SlideAnimation(
                  verticalOffset: 20,
                  child: FadeInAnimation(
                    child: AppCard(
                      interactive: true,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final column in columns) ...[
                            Text(
                              column.label,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 6),
                            column.cellBuilder(item),
                            if (column != columns.last)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                child: Divider(),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable2(
              columnSpacing: 20,
              horizontalMargin: 16,
              smRatio: 0.7,
              lmRatio: 1.4,
              minWidth: columns.length * 180,
              headingRowHeight: 52,
              dataRowHeight: 72,
              columns: [
                for (final column in columns)
                  DataColumn2(size: column.size, label: Text(column.label)),
              ],
              rows: [
                for (var index = 0; index < items.length; index++)
                  DataRow2(
                    color: MaterialStatePropertyAll(
                      index.isEven
                          ? Colors.transparent
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.02),
                    ),
                    cells: [
                      for (final column in columns)
                        DataCell(column.cellBuilder(items[index])),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
