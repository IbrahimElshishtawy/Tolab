import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/upload_model.dart';
import 'progress_indicator.dart';

class UploadCard extends StatelessWidget {
  const UploadCard({
    super.key,
    required this.item,
    required this.selected,
    required this.onSelected,
    required this.onPreview,
    required this.onDelete,
    required this.onAssign,
    this.onRetry,
    this.onCancel,
  });

  final UploadItem item;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final VoidCallback onPreview;
  final VoidCallback onDelete;
  final VoidCallback onAssign;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      interactive: true,
      borderColor: selected ? AppColors.primary.withValues(alpha: 0.35) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox.adaptive(
                value: selected,
                onChanged: (value) => onSelected(value ?? false),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: item.type.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppConstants.smallRadius,
                        ),
                      ),
                      child: Icon(item.type.icon, color: item.type.accent),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.type.label} | ${_formatFileSize(item.sizeBytes)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(item.status.label),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _InfoPill(
                icon: Icons.layers_rounded,
                label: item.assignment.materialLabel,
              ),
              _InfoPill(
                icon: Icons.dashboard_customize_rounded,
                label: item.assignment.sectionLabel,
              ),
              _InfoPill(icon: Icons.person_rounded, label: item.uploadedBy),
              _InfoPill(
                icon: Icons.event_rounded,
                label: DateFormat('dd MMM yyyy').format(item.uploadedAt),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          UploadsProgressIndicator(
            progress: item.progress,
            status: item.status,
          ),
          if (item.errorMessage != null && item.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              PremiumButton(
                label: 'Preview',
                icon: Icons.visibility_rounded,
                isSecondary: true,
                onPressed: onPreview,
              ),
              PremiumButton(
                label: 'Assign',
                icon: Icons.rule_folder_rounded,
                isSecondary: true,
                onPressed: onAssign,
              ),
              if (item.isFailed)
                PremiumButton(
                  label: 'Retry',
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              if (item.isUploading)
                PremiumButton(
                  label: 'Cancel',
                  icon: Icons.close_rounded,
                  isSecondary: true,
                  onPressed: onCancel,
                ),
              PremiumButton(
                label: 'Delete',
                icon: Icons.delete_outline_rounded,
                isSecondary: true,
                isDestructive: item.isFailed && !item.isUploading,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

String _formatFileSize(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
}
