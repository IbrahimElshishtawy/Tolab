import 'package:flutter/material.dart';

import '../../../../../app_admin/core/colors/app_colors.dart';
import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../../../../../app_admin/shared/widgets/premium_button.dart';
import '../../../../../app_admin/shared/widgets/status_badge.dart';
import '../../../../core/models/academic_models.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.onOpen,
  });

  final SubjectModel subject;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final progressColor = subject.progress >= 0.75
        ? const Color(0xFF14B8A6)
        : subject.progress >= 0.6
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return AppCard(
      interactive: true,
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StatusBadge(subject.code),
                    if (subject.levelLabel.isNotEmpty) StatusBadge(subject.levelLabel),
                    StatusBadge(subject.statusLabel),
                  ],
                ),
              ),
              const Icon(Icons.arrow_outward_rounded, size: 18),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            subject.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subject.departmentName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _MetricPill(
                icon: Icons.groups_rounded,
                label: '${subject.studentCount} students',
              ),
              _MetricPill(
                icon: Icons.widgets_rounded,
                label: '${subject.sectionsCount} sections',
              ),
              _MetricPill(
                icon: Icons.quiz_rounded,
                label: '${subject.quizzesCount} quizzes',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: subject.progress,
              minHeight: 8,
              backgroundColor: progressColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${(subject.progress * 100).round()}% course delivery progress',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                subject.lastActivityLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if ((subject.doctorName ?? '').isNotEmpty)
                _NamedLine(
                  icon: Icons.person_rounded,
                  text: subject.doctorName!,
                ),
              if ((subject.assistantName ?? '').isNotEmpty)
                _NamedLine(
                  icon: Icons.support_agent_rounded,
                  text: subject.assistantName!,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Avg ${subject.averageScore.toStringAsFixed(1)}% · ${subject.pendingGradesCount} pending review',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              PremiumButton(
                label: 'Open',
                icon: Icons.arrow_forward_rounded,
                onPressed: onOpen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _NamedLine extends StatelessWidget {
  const _NamedLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.info),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
