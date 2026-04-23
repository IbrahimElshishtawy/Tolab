import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../models/analytics_workspace_models.dart';

class AnalyticsPeriodInsightsSection extends StatelessWidget {
  const AnalyticsPeriodInsightsSection({super.key, required this.items});

  final List<AnalyticsPeriodInsight> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weekly / monthly insights', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'These trends explain where the teaching load is moving next, not just where it stands right now.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: items
              .map(
                (item) => SizedBox(
                  width: 260,
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.label, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.value,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.deltaLabel,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: item.color,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          item.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
