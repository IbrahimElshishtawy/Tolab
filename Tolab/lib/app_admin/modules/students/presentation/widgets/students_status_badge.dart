import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../design/students_admin_tokens.dart';

class StudentsStatusBadge extends StatelessWidget {
  const StudentsStatusBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tone = StudentsAdminBadges.toneForStatus(label);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: tone.foreground.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: tone.foreground),
      ),
    );
  }
}
