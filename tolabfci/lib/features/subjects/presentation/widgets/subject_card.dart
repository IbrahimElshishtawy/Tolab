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
  const SubjectCard({super.key, required this.subject, required this.onTap});

  final SubjectOverview subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(subject.accentHex);
    final palette = context.appColors;

    return AppCard(
      backgroundColor: palette.surfaceElevated,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.auto_stories_rounded, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${subject.code} • ${subject.creditHours} ساعات',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: subject.status,
                backgroundColor: accent.withValues(alpha: 0.14),
                foregroundColor: accent,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subject.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MiniChip(label: 'الدكتور', value: subject.instructor),
              _MiniChip(label: 'المعيد', value: subject.assistantName),
              _MiniChip(label: 'المحاضرات', value: '${subject.lecturesCount}'),
              _MiniChip(label: 'السكاشن', value: '${subject.sectionsCount}'),
              _MiniChip(label: 'الكويزات', value: '${subject.quizCount}'),
              _MiniChip(label: 'التكليفات', value: '${subject.sheetCount}'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'آخر نشاط',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const Spacer(),
                    Text(
                      '${(subject.progress * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subject.lastActivityLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: subject.progress,
                    minHeight: 7,
                    backgroundColor: palette.surface,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: 'فتح المادة',
                onPressed: onTap,
                isExpanded: false,
                icon: Icons.arrow_forward_rounded,
              ),
              AppButton(
                label: 'الجروب',
                onPressed: () => _openTab(context, 'group'),
                isExpanded: false,
                variant: AppButtonVariant.secondary,
                icon: Icons.forum_outlined,
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

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

Color _accentColor(String hex) {
  final sanitized = hex.replaceAll('#', '');
  return Color(int.parse('FF$sanitized', radix: 16));
}
