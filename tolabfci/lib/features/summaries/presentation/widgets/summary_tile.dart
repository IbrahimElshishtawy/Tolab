import 'package:flutter/material.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

class SummaryTile extends StatelessWidget {
  const SummaryTile({super.key, required this.summary});

  final SummaryItem summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (summary.attachmentName != null)
                AppBadge(label: summary.attachmentName!),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('By ${summary.authorName} • ${summary.createdAtLabel}'),
          if (summary.videoUrl != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              summary.videoUrl!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
