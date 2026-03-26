import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../data/models/admin_models.dart';

class AdminTableColumn<T> {
  const AdminTableColumn({required this.label, required this.cellBuilder});

  final String label;
  final String Function(T item) cellBuilder;
}

class AdminDataTable<T extends AdminEntity> extends StatelessWidget {
  const AdminDataTable({
    super.key,
    required this.items,
    required this.columns,
    this.onTap,
    this.actionsBuilder,
  });

  final List<T> items;
  final List<AdminTableColumn<T>> columns;
  final ValueChanged<T>? onTap;
  final List<Widget> Function(T item)? actionsBuilder;

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 16,
      minWidth: 720,
      columns: [
        ...columns.map((column) => DataColumn2(label: Text(column.label))),
        const DataColumn2(label: Text('Actions'), fixedWidth: 120),
      ],
      rows: items.map((item) {
        return DataRow2(
          onTap: onTap == null ? null : () => onTap!(item),
          cells: [
            ...columns.map(
              (column) => DataCell(Text(column.cellBuilder(item))),
            ),
            DataCell(
              Row(
                children:
                    actionsBuilder?.call(item) ??
                    [const Icon(Icons.arrow_forward_ios_rounded, size: 14)],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
