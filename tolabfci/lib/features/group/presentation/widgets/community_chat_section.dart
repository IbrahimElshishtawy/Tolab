import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../chat/presentation/widgets/chat_panel.dart';
import '../../../subject_details/presentation/providers/chat_providers.dart';

class CommunityChatSection extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final chatAsync = ref.watch(chatControllerProvider(subjectId));
    final messages = chatAsync.asData?.value.messages;
    final latestMessage = messages == null || messages.isEmpty
        ? null
        : messages.last;

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
            if (latestMessage != null)
              AppBadge(
                label:
                    '${latestMessage.authorName} • ${latestMessage.sentAtLabel}',
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
