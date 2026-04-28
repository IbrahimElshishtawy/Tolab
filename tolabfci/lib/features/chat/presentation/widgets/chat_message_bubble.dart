import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/community_models.dart';
import '../../../../core/services/root_scaffold_messenger.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message, this.onDelete});

  final ChatMessage message;
  final VoidCallback? onDelete;

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
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onLongPress: () => _showMessageActions(context),
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
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: roleColor.withValues(alpha: 0.16),
                    child: Text(
                      _avatarInitial(message.authorName),
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.sentAtLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (message.isMine) ...[
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.done_all_rounded,
                      size: 15,
                      color: AppColors.success,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Copy'),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: message.content));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  showRootSnackBar('تم نسخ الرسالة');
                },
              ),
              if (message.isMine)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Delete my message'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onDelete?.call();
                    showRootSnackBar('تم حذف رسالتك');
                  },
                ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report'),
                onTap: () {
                  Navigator.of(context).pop();
                  showRootSnackBar('تم إرسال البلاغ للمشرف');
                },
              ),
            ],
          ),
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

String _avatarInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return trimmed.substring(0, 1);
}
