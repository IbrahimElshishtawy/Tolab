import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';

class EnrollmentProgressWidget extends StatelessWidget {
  const EnrollmentProgressWidget({
    super.key,
    required this.value,
    required this.label,
    required this.trailing,
  });

  final double value;
  final String label;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final accent = clamped >= 0.9
        ? AppColors.danger
        : clamped >= 0.72
        ? AppColors.warning
        : AppColors.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
            Text(trailing, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.pillRadius),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 10,
            backgroundColor: accent.withValues(alpha: 0.10),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }
}
