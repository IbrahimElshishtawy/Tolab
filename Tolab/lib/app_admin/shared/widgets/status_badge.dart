import 'package:flutter/material.dart';

import '../../core/colors/app_colors.dart';
import '../../core/constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    final color = switch (lower) {
      'live' ||
      'active' ||
      'published' ||
      'scheduled' ||
      'delivered' ||
      'completed' => AppColors.secondary,
      'draft' || 'pending' || 'queued' || 'planned' => AppColors.warning,
      'flagged' ||
      'inactive' ||
      'blocked' ||
      'failed' ||
      'overdue' => AppColors.danger,
      'doctor' || 'super admin' => AppColors.purple,
      'assistant' || 'message' => AppColors.info,
      _ => AppColors.info,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
          ],
          Text(
            label,
            softWrap: true,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
