import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/upload_model.dart';
import 'progress_indicator.dart';

class UploadTable extends StatelessWidget {
  const UploadTable({
    super.key,
    required this.items,
    required this.selectedIds,
    required this.onToggleSelection,
    required this.onToggleAll,
    required this.onPreview,
    required this.onDelete,
    required this.onAssign,
    this.onRetry,
    this.onCancel,
  });

  final List<UploadItem> items;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggleSelection;
  final ValueChanged<bool> onToggleAll;
  final ValueChanged<UploadItem> onPreview;
  final ValueChanged<UploadItem> onDelete;
  final ValueChanged<UploadItem> onAssign;
  final ValueChanged<UploadItem>? onRetry;
  final ValueChanged<UploadItem>? onCancel;

  @override
  Widget build(BuildContext context) {
    final allSelected =
        items.isNotEmpty &&
        items.every((item) => selectedIds.contains(item.id));

    return AppCard(
      padding: EdgeInsets.zero,
      child: DataTable2(
        headingRowHeight: 58,
        dataRowHeight: 84,
        columnSpacing: 14,
        horizontalMargin: 16,
        minWidth: 1120,
        columns: [
          DataColumn2(
            fixedWidth: 52,
            label: Checkbox.adaptive(
              value: allSelected,
              tristate: false,
              onChanged: (value) => onToggleAll(value ?? false),
            ),
          ),
          const DataColumn2(label: Text('Name'), size: ColumnSize.L),
          const DataColumn2(label: Text('Type'), size: ColumnSize.S),
          const DataColumn2(label: Text('Size'), size: ColumnSize.S),
          const DataColumn2(
            label: Text('Material / Section'),
            size: ColumnSize.L,
          ),
          const DataColumn2(label: Text('Uploaded By'), size: ColumnSize.M),
          const DataColumn2(label: Text('Date'), size: ColumnSize.M),
          const DataColumn2(label: Text('Status'), size: ColumnSize.M),
          const DataColumn2(label: Text('Actions'), size: ColumnSize.M),
        ],
        rows: [
          for (final item in items)
            DataRow2(
              onTap: () => onPreview(item),
              color: WidgetStatePropertyAll(
                selectedIds.contains(item.id)
                    ? AppColors.primary.withValues(alpha: 0.06)
                    : Colors.transparent,
              ),
              cells: [
                DataCell(
                  Checkbox.adaptive(
                    value: selectedIds.contains(item.id),
                    onChanged: (_) => onToggleSelection(item.id),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: item.type.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(item.type.icon, color: item.type.accent),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.accessControl.level.label,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(item.type.label)),
                DataCell(Text(_formatFileSize(item.sizeBytes))),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.assignment.materialLabel),
                      const SizedBox(height: 4),
                      Text(
                        item.assignment.sectionLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DataCell(Text(item.uploadedBy)),
                DataCell(
                  Text(DateFormat('dd MMM yyyy').format(item.uploadedAt)),
                ),
                DataCell(
                  SizedBox(
                    width: 180,
                    child: item.isUploading
                        ? UploadsProgressIndicator(
                            progress: item.progress,
                            status: item.status,
                            compact: true,
                          )
                        : StatusBadge(item.status.label),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Preview',
                        onPressed: () => onPreview(item),
                        icon: const Icon(Icons.visibility_rounded),
                      ),
                      IconButton(
                        tooltip: 'Assign',
                        onPressed: () => onAssign(item),
                        icon: const Icon(Icons.rule_folder_rounded),
                      ),
                      if (item.isFailed)
                        IconButton(
                          tooltip: 'Retry',
                          onPressed: onRetry == null
                              ? null
                              : () => onRetry!(item),
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      if (item.isUploading)
                        IconButton(
                          tooltip: 'Cancel',
                          onPressed: onCancel == null
                              ? null
                              : () => onCancel!(item),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => onDelete(item),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

String _formatFileSize(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
}
