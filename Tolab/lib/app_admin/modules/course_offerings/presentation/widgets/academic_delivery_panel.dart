import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/course_offering_model.dart';
import 'offering_summary_card.dart';

class AcademicDeliveryPanel extends StatelessWidget {
  const AcademicDeliveryPanel({super.key, required this.offerings});

  final List<CourseOfferingModel> offerings;

  @override
  Widget build(BuildContext context) {
    final active = offerings
        .where((item) => item.status == CourseOfferingStatus.active)
        .length;
    final highDemand = offerings.where((item) => item.fillRate >= 0.85).length;
    final departments = offerings.map((item) => item.departmentName).toSet();
    final academicYears = offerings.map((item) => item.academicYear).toSet();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.byValue('Academic delivery snapshot'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.byValue('A cleaner split for active delivery, demand pressure, and academic coverage across the current offerings view.'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OfferingInsightChip(
                label: '$active ${context.l10n.byValue('active now')}',
                color: AppColors.secondary,
              ),
              OfferingInsightChip(
                label: '$highDemand ${context.l10n.byValue('high-demand sections')}',
                color: AppColors.warning,
              ),
              OfferingInsightChip(
                label: '${departments.length} ${context.l10n.byValue('departments')}',
                color: AppColors.info,
              ),
              OfferingInsightChip(
                label: academicYears.isEmpty
                    ? context.l10n.byValue('No academic year data')
                    : academicYears.map((y) => context.l10n.byValue(y)).join(' • '),
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
