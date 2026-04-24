import 'package:flutter/material.dart';

import '../../../../core/models/community_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final roleColor = _roleColor(message.authorRole);
    final alignment = message.isMine
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final background = message.isMine
        ? AppColors.primary.withValues(alpha: 0.16)
        : palette.surfaceAlt;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: message.isMine
                ? AppColors.primary.withValues(alpha: 0.20)
                : palette.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  message.authorName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppBadge(
                  label: _roleLabel(message.authorRole),
                  backgroundColor: roleColor.withValues(alpha: 0.12),
                  foregroundColor: roleColor,
                  dense: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message.sentAtLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

String _roleLabel(String role) {
  return switch (role.toLowerCase()) {
    'doctor' => 'دكتور',
    'assistant' => 'معيد',
    _ => 'طالب',
  };
}

Color _roleColor(String role) {
  return switch (role.toLowerCase()) {
    'doctor' => AppColors.error,
    'assistant' => AppColors.warning,
    _ => AppColors.primary,
  };
}
