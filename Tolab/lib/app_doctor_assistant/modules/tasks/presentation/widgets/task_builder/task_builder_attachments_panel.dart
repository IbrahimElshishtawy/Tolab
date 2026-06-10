import 'package:flutter/material.dart';

import '../../../../../core/design/app_spacing.dart';
import '../../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';

class TaskAttachmentDraft {
  const TaskAttachmentDraft({required this.fileName, required this.fileType});

  final String fileName;
  final String fileType;

  Map<String, dynamic> toJson() => {
    'file_name': fileName,
    'file_type': fileType,
  };
}

class TaskBuilderAttachmentsPanel extends StatelessWidget {
  const TaskBuilderAttachmentsPanel({
    super.key,
    required this.attachments,
    required this.onAddAttachment,
    required this.onRemoveAttachment,
  });

  final List<TaskAttachmentDraft> attachments;
  final VoidCallback onAddAttachment;
  final ValueChanged<TaskAttachmentDraft> onRemoveAttachment;

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
                  'Attachments upload',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddAttachment,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Upload attachment'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            attachments.isEmpty
                ? 'No files attached yet. Add task briefs, rubrics, templates, or datasets.'
                : 'Attached files',
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
                  .map((attachment) {
                    return InputChip(
                      avatar: const Icon(Icons.attach_file_rounded, size: 18),
                      label: Text(
                        '${attachment.fileName} - ${attachment.fileType}',
                      ),
                      onDeleted: () => onRemoveAttachment(attachment),
                    );
                  })
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}
