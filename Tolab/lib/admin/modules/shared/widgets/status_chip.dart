import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'active' || 'confirmed' || 'current' || 'sent' => AppColors.success,
      'review' || 'pending' || 'updated' || 'action' => AppColors.warning,
      'leave' || 'archived' => AppColors.danger,
      _ => AppColors.info,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
