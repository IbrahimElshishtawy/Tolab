import 'package:flutter/material.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

class SubjectDetailsHeader extends StatelessWidget {
  const SubjectDetailsHeader({super.key, required this.subject});

  final SubjectOverview subject;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(subject.accentHex);

    return AppCard(
      backgroundColor: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subject.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: subject.status,
                backgroundColor: accent.withValues(alpha: 0.10),
                foregroundColor: accent,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(label: subject.code, backgroundColor: Colors.white),
              AppBadge(
                label: subject.instructor,
                backgroundColor: Colors.white,
              ),
              AppBadge(
                label: 'المعيد: ${subject.assistantName}',
                backgroundColor: Colors.white,
              ),
              AppBadge(
                label: '${subject.creditHours} ساعات',
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _accentColor(String hex) {
  final sanitized = hex.replaceAll('#', '');
  return Color(int.parse('FF$sanitized', radix: 16));
}
