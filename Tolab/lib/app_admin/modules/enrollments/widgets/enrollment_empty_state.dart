import 'package:flutter/material.dart';

import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/widgets/premium_button.dart';

class EnrollmentEmptyState extends StatelessWidget {
  const EnrollmentEmptyState({
    super.key,
    required this.onCreate,
    required this.onBulkUpload,
  });

  final VoidCallback onCreate;
  final VoidCallback onBulkUpload;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_turned_in_outlined, size: 42),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No enrollments match the current view',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Create a manual enrollment or import a validated roster to populate this workspace.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              PremiumButton(
                label: 'Add enrollment',
                icon: Icons.add_rounded,
                onPressed: onCreate,
              ),
              PremiumButton(
                label: 'Bulk upload',
                icon: Icons.upload_file_rounded,
                isSecondary: true,
                onPressed: onBulkUpload,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
