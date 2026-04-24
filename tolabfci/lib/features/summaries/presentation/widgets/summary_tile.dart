import 'package:flutter/material.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class SummaryTile extends StatelessWidget {
  const SummaryTile({super.key, required this.summary});

  final SummaryItem summary;

  @override
  Widget build(BuildContext context) {
    final fileName = summary.attachmentName ?? 'summary-details';
    final hasLink = summary.videoUrl?.trim().isNotEmpty ?? false;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      backgroundColor: context.appColors.surfaceElevated,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        AppBadge(label: fileName, dense: true),
                        AppBadge(label: summary.authorName, dense: true),
                        AppBadge(label: summary.createdAtLabel, dense: true),
                        if (hasLink)
                          AppBadge(
                            label: 'رابط',
                            backgroundColor: AppColors.success.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: AppColors.success,
                            dense: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final action = AppButton(
            label: 'فتح الملخص',
            onPressed: () => _openSummaryDetails(context),
            isExpanded: compact,
            icon: Icons.open_in_new_rounded,
            variant: AppButtonVariant.secondary,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: AppSpacing.sm),
                action,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: content),
              const SizedBox(width: AppSpacing.sm),
              action,
            ],
          );
        },
      ),
    );
  }

  void _openSummaryDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailLine(label: 'الملف', value: summary.attachmentName ?? '-'),
              _DetailLine(label: 'الكاتب', value: summary.authorName),
              _DetailLine(label: 'التاريخ', value: summary.createdAtLabel),
              if (summary.videoUrl != null)
                _DetailLine(label: 'الرابط', value: summary.videoUrl!),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'تم',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
