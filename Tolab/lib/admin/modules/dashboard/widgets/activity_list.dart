import 'package:flutter/material.dart';

import '../../../core/values/app_spacing.dart';
import '../../../data/models/admin_models.dart';
import '../../shared/widgets/status_chip.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key, required this.items});

  final List<ActivityItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(radius: 6),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.relativeLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    StatusChip(item.status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
