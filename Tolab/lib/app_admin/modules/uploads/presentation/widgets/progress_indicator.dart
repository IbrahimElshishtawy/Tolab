import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/upload_model.dart';

class UploadsProgressIndicator extends StatelessWidget {
  const UploadsProgressIndicator({
    super.key,
    required this.progress,
    required this.status,
    this.compact = false,
  });

  final double progress;
  final UploadStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0).toDouble();
    final color = switch (status) {
      UploadStatus.uploaded => AppColors.secondary,
      UploadStatus.uploading => AppColors.primary,
      UploadStatus.failed => AppColors.danger,
      UploadStatus.cancelled => AppColors.warning,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                child: LinearProgressIndicator(
                  value: status == UploadStatus.failed ? 1 : value,
                  minHeight: compact ? 6 : 8,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(status.label),
            ],
          ],
        ),
        if (!compact) ...[
          const SizedBox(height: AppSpacing.xs),
          AnimatedSwitcher(
            duration: AppMotion.fast,
            child: Text(
              status == UploadStatus.uploaded
                  ? '100% completed'
                  : status == UploadStatus.failed
                  ? 'Upload interrupted'
                  : status == UploadStatus.cancelled
                  ? 'Cancelled'
                  : '${(value * 100).round()}% uploading',
              key: ValueKey('${status.name}-$value'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }
}
