import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../chat/presentation/widgets/chat_panel.dart';

class CommunityChatSection extends StatelessWidget {
  const CommunityChatSection({
    super.key,
    required this.subjectId,
    this.unreadCount = 0,
    this.height = 560,
  });

  final String subjectId;
  final int unreadCount;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'الجروب / Course Group',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (unreadCount > 0)
              AppBadge(
                label: '$unreadCount غير مقروء',
                backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                foregroundColor: AppColors.warning,
                dense: true,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: height,
          child: ChatPanel(
            subjectId: subjectId,
            fillAvailable: true,
            compact: true,
          ),
        ),
      ],
    );
  }
}
