import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/home_providers.dart';

class TodayFocusSection extends StatelessWidget {
  const TodayFocusSection({super.key, required this.model});

  final StudentTodayFocusModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (model.state) {
      StudentTodayFocusState.urgent => AppColors.error,
      StudentTodayFocusState.busy => AppColors.primary,
      StudentTodayFocusState.empty => AppColors.teal,
    };

    return AppCard(
      backgroundColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _stateLabel(model.state),
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            model.title,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            model.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: model.highlights
                .map((highlight) => _FocusHighlightTile(highlight: highlight))
                .toList(),
          ),
          if (model.primaryCta != null || model.secondaryCta != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (model.primaryCta != null)
                  FilledButton(
                    onPressed: () =>
                        _openTarget(context, model.primaryCta!.target),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color,
                    ),
                    child: Text(model.primaryCta!.label),
                  ),
                if (model.secondaryCta != null)
                  OutlinedButton(
                    onPressed: () =>
                        _openTarget(context, model.secondaryCta!.target),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: Text(model.secondaryCta!.label),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FocusHighlightTile extends StatelessWidget {
  const _FocusHighlightTile({required this.highlight});

  final StudentTodayHighlight highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            highlight.label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            highlight.value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _stateLabel(StudentTodayFocusState state) {
  switch (state) {
    case StudentTodayFocusState.urgent:
      return 'Today focus';
    case StudentTodayFocusState.busy:
      return 'Up next';
    case StudentTodayFocusState.empty:
      return 'All clear';
  }
}

void _openTarget(BuildContext context, StudentActionTarget target) {
  context.goNamed(target.routeName, pathParameters: target.pathParameters);
}
