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
      backgroundColor: context.appColors.surfaceElevated,
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
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(label: subject.code, dense: true),
              AppBadge(label: subject.instructor, dense: true),
              AppBadge(label: 'المعيد: ${subject.assistantName}', dense: true),
              AppBadge(label: '${subject.creditHours} ساعات', dense: true),
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
