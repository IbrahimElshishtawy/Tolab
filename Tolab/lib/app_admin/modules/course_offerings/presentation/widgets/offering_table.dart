import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/course_offering_model.dart';
import 'offering_card.dart';

class OfferingTable extends StatelessWidget {
  const OfferingTable({
    super.key,
    required this.offerings,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CourseOfferingModel> offerings;
  final ValueChanged<CourseOfferingModel> onView;
  final ValueChanged<CourseOfferingModel> onEdit;
  final ValueChanged<CourseOfferingModel> onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: DataTable2(
        minWidth: 1080,
        columnSpacing: 18,
        horizontalMargin: 18,
        headingRowHeight: 56,
        dataRowHeight: 84,
        columns: [
          DataColumn2(
            label: Text(context.l10n.byValue('Subject')),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Code')),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Doctor')),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Semester')),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Capacity')),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Status')),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text(context.l10n.byValue('Actions')),
            size: ColumnSize.M,
          ),
        ],
        rows: [
          for (var index = 0; index < offerings.length; index++)
            DataRow2(
              color: WidgetStatePropertyAll(
                index.isEven
                    ? Colors.transparent
                    : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.03),
              ),
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.byValue(offerings[index].subjectName),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.byValue(offerings[index].sectionName),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DataCell(Text(offerings[index].code)),
                DataCell(Text(offerings[index].doctor.name)),
                DataCell(
                  Text(
                    '${context.l10n.byValue(offerings[index].semester)}\n${offerings[index].academicYear}',
                  ),
                ),
                DataCell(_CapacityCell(offering: offerings[index])),
                DataCell(OfferingStatusBadge(status: offerings[index].status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => onView(offerings[index]),
                        icon: const Icon(Icons.visibility_outlined),
                      ),
                      IconButton(
                        onPressed: () => onEdit(offerings[index]),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => onDelete(offerings[index]),
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

class _CapacityCell extends StatelessWidget {
  const _CapacityCell({required this.offering});

  final CourseOfferingModel offering;

  @override
  Widget build(BuildContext context) {
    final color = offering.fillRate >= 0.95
        ? AppColors.danger
        : offering.fillRate >= 0.75
        ? AppColors.warning
        : AppColors.secondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${offering.enrolledCount}/${offering.capacity} ${context.l10n.byValue('enrolled')}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.pillRadius),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: offering.fillRate.clamp(0, 1),
            backgroundColor: color.withValues(alpha: 0.14),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${offering.seatsRemaining} ${context.l10n.byValue('seats left')} - ${DateFormat('d MMM', context.l10n.locale.languageCode).format(offering.startDate)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
