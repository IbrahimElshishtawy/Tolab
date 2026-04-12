import 'package:flutter/material.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

class SubjectDetailsHeader extends StatelessWidget {
  const SubjectDetailsHeader({
    super.key,
    required this.subject,
  });

  final SubjectOverview subject;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subject.name, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(subject.description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(label: subject.code),
              AppBadge(label: subject.instructor),
              AppBadge(label: '${subject.creditHours} credit hours'),
            ],
          ),
        ],
      ),
    );
  }
}
