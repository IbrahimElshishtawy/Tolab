import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import 'package:tolab_fci/app/localization/app_localizations.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1280;
        final rowHeight = isCompact ? 64.0 : 72.0;
        final headingRowHeight = isCompact ? 46.0 : 52.0;
        final iconBoxSize = isCompact ? 34.0 : 38.0;
        final minTableWidth = (isCompact ? 980 : 1120).toDouble();
        final resolvedWidth = math.max(constraints.maxWidth, minTableWidth);
        final tableHeight = headingRowHeight + (items.length * rowHeight) + 8;

        return AppCard(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: resolvedWidth,
              child: SizedBox(
                height: tableHeight,
                child: DataTable2(
                  headingRowHeight: headingRowHeight,
                  dataRowHeight: rowHeight,
                  columnSpacing: isCompact ? 8 : 12,
                  horizontalMargin: isCompact ? 10 : 14,
                  minWidth: resolvedWidth,
                  smRatio: 0.72,
                  lmRatio: 1.25,
                  columns: [
                    DataColumn2(
                      fixedWidth: 48,
                      label: Checkbox.adaptive(
                        value: allSelected,
                        tristate: false,
                        onChanged: (value) => onToggleAll(value ?? false),
                      ),
                    ),
                    DataColumn2(label: Text(context.l10n.byValue('Name')), size: ColumnSize.L),
                    DataColumn2(label: Text(context.l10n.byValue('Type')), size: ColumnSize.S),
                    DataColumn2(label: Text(context.l10n.byValue('Size')), size: ColumnSize.S),
                    DataColumn2(
                      label: Text(context.l10n.byValue('Material / Section')),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: Text(context.l10n.byValue('Uploaded By')),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(label: Text(context.l10n.byValue('Date')), size: ColumnSize.M),
                    DataColumn2(
                      label: Text(context.l10n.byValue('Status')),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text(context.l10n.byValue('Actions')),
                      size: ColumnSize.M,
                    ),
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
                                  height: iconBoxSize,
                                  width: iconBoxSize,
                                  decoration: BoxDecoration(
                                    color: item.type.accent.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      isCompact ? 10 : 14,
                                    ),
                                  ),
                                  child: Icon(
                                    item.type.icon,
                                    color: item.type.accent,
                                    size: isCompact ? 16 : 18,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        context.l10n.byValue(item.accessControl.level.label),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(context.l10n.byValue(item.type.label))),
                          DataCell(Text(_formatFileSize(context, item.sizeBytes))),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.assignment.materialLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.assignment.sectionLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              item.uploadedBy,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(
                            Text(
                              DateFormat('dd MMM yyyy', context.l10n.locale.languageCode).format(item.uploadedAt),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: isCompact ? 148 : 170,
                              child: item.isUploading
                                  ? UploadsProgressIndicator(
                                      progress: item.progress,
                                      status: item.status,
                                      compact: true,
                                      )
                                  : StatusBadge(context.l10n.byValue(item.status.label)),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  tooltip: context.l10n.byValue('Preview'),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => onPreview(item),
                                  icon: const Icon(Icons.visibility_rounded),
                                ),
                                IconButton(
                                  tooltip: context.l10n.byValue('Assign'),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => onAssign(item),
                                  icon: const Icon(Icons.rule_folder_rounded),
                                ),
                                if (item.isFailed)
                                  IconButton(
                                    tooltip: context.l10n.byValue('Retry'),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: onRetry == null
                                        ? null
                                        : () => onRetry!(item),
                                    icon: const Icon(Icons.refresh_rounded),
                                  ),
                                if (item.isUploading)
                                  IconButton(
                                    tooltip: context.l10n.byValue('Cancel'),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: onCancel == null
                                        ? null
                                        : () => onCancel!(item),
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                                IconButton(
                                  tooltip: context.l10n.byValue('Delete'),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => onDelete(item),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _formatFileSize(BuildContext context, int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${context.l10n.byValue(units[unitIndex])}';
}
