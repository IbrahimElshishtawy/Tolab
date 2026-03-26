import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

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
    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 12,
      minWidth: 860,
      columns: [
        for (final column in columns)
          DataColumn2(size: column.size, label: Text(column.label)),
      ],
      rows: [
        for (final item in items)
          DataRow2(
            cells: [
              for (final column in columns) DataCell(column.cellBuilder(item)),
            ],
          ),
      ],
    );
  }
}
