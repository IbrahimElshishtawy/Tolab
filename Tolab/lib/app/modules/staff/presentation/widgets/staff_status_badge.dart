import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../design/staff_management_tokens.dart';

class StaffStatusBadge extends StatelessWidget {
  const StaffStatusBadge(this.label, {super.key, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tone = StaffManagementBadges.toneForLabel(context, label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: tone.foreground.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: tone.foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: tone.foreground),
          ),
        ],
      ),
    );
  }
}
