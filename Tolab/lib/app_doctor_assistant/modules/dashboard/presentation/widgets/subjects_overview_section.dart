import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'subject_overview_card.dart';

class SubjectsOverviewSection extends StatelessWidget {
  const SubjectsOverviewSection({
    super.key,
    required this.subjects,
    required this.onOpenRoute,
  });

  final List<DashboardSubjectPreview> subjects;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'My Subjects Overview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: () => onOpenRoute('/workspace/subjects'),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: DashboardAppSpacing.sm),
        Text(
          'Track teaching load, student volume, and fast subject actions.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: DashboardAppSpacing.md),
        for (final subject in subjects) ...[
          SubjectOverviewCard(subject: subject, onOpenRoute: onOpenRoute),
          if (subject != subjects.last)
            const SizedBox(height: DashboardAppSpacing.md),
        ],
      ],
    );
  }
}
