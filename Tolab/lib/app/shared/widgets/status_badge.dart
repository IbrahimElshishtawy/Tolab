import 'package:flutter/material.dart';

import '../../core/colors/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    final color = switch (lower) {
      'active' ||
      'published' ||
      'scheduled' ||
      'delivered' => AppColors.secondary,
      'draft' || 'pending' || 'queued' => AppColors.warning,
      'flagged' || 'inactive' || 'blocked' || 'failed' => AppColors.danger,
      _ => AppColors.info,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
