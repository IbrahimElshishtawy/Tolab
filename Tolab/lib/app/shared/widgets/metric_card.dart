import 'package:flutter/material.dart';

import '../../core/widgets/app_card.dart';
import '../models/dashboard_models.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.metric});

  final KpiMetric metric;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: metric.color.withValues(alpha: 0.14),
            child: Icon(metric.icon, color: metric.color),
          ),
          const SizedBox(height: 18),
          Text(metric.label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(metric.value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            metric.delta,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: metric.color),
          ),
        ],
      ),
    );
  }
}
