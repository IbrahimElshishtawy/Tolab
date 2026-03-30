import 'package:flutter/material.dart';

import '../../core/colors/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_card.dart';
import '../models/dashboard_models.dart';
import 'status_badge.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.metric});

  final KpiMetric metric;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      interactive: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                ),
                child: Icon(metric.icon, color: metric.color),
              ),
              const Spacer(),
              StatusBadge(
                metric.delta.split(' ').first,
                icon: Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            metric.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(metric.value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            metric.delta,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: metric.color),
          ),
          const SizedBox(height: 18),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.slateSoft.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: switch (metric.label) {
                'Active students' => 0.82,
                'Academic staff' => 0.61,
                'Schedule events' => 0.74,
                _ => 0.38,
              },
              child: Container(
                decoration: BoxDecoration(
                  color: metric.color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
