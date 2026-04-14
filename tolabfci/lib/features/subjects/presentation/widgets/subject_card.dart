import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  final SubjectOverview subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(subject.accentHex);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 64,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${subject.code} - ${subject.instructor}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'المعيد: ${subject.assistantName}',
                      style: Theme.of(context).textTheme.labelLarge,
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
          Text(subject.description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaBadge(label: 'المحاضرات', value: '${subject.lecturesCount}'),
              _MetaBadge(label: 'السكاشن', value: '${subject.sectionsCount}'),
              _MetaBadge(label: 'الكويزات', value: '${subject.quizCount}'),
              _MetaBadge(label: 'الشيتات', value: '${subject.sheetCount}'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('آخر نشاط', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(subject.lastActivityLabel),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: subject.progress,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    color: accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'نسبة التقدم ${(subject.progress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(label: 'فتح المادة', onPressed: onTap, isExpanded: false),
              AppButton(
                label: 'دخول الجروب',
                onPressed: () => _openTab(context, 'group'),
                isExpanded: false,
                variant: AppButtonVariant.secondary,
              ),
              AppButton(
                label: 'عرض المحتوى',
                onPressed: () => _openTab(context, 'lectures'),
                isExpanded: false,
                variant: AppButtonVariant.secondary,
              ),
              AppButton(
                label: 'عرض الشيتات',
                onPressed: () => _openTab(context, 'tasks'),
                isExpanded: false,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openTab(BuildContext context, String tab) {
    context.goNamed(
      RouteNames.subjectDetails,
      pathParameters: {'subjectId': subject.id},
      queryParameters: {'tab': tab},
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: $value', style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

Color _accentColor(String hex) {
  final sanitized = hex.replaceAll('#', '');
  return Color(int.parse('FF$sanitized', radix: 16));
}
