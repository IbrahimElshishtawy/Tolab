import 'package:flutter/material.dart';

import '../../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../../../core/design/app_spacing.dart';

class QuizBuilderAttachmentsPanel extends StatelessWidget {
  const QuizBuilderAttachmentsPanel({
    super.key,
    required this.attachments,
    required this.onAddAttachment,
    required this.onRemoveAttachment,
  });

  final List<String> attachments;
  final VoidCallback onAddAttachment;
  final ValueChanged<String> onRemoveAttachment;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Attachment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddAttachment,
                icon: const Icon(Icons.attach_file_rounded),
                label: const Text('Add file'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            attachments.isEmpty ? 'No attachment yet.' : 'Attached file set',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: attachments
                  .map(
                    (item) => InputChip(
                      label: Text(item),
                      avatar: const Icon(
                        Icons.insert_drive_file_rounded,
                        size: 18,
                      ),
                      onDeleted: () => onRemoveAttachment(item),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}
