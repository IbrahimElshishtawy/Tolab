import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../models/enrollment_models.dart';

class EnrollmentBadgeWidget extends StatelessWidget {
  const EnrollmentBadgeWidget(this.status, {super.key});

  final EnrollmentStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
