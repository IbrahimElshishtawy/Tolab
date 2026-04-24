import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/community_providers.dart';
import 'comments_sheet.dart';
import 'post_reactions_row.dart';

class CommunityPostCard extends ConsumerWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    required this.subjectId,
  });

  final CommunityPost post;
  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _postColor(post.type);

    return AppCard(
      backgroundColor: context.appColors.surfaceElevated,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                post.authorName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppBadge(
                label: post.authorRole,
                backgroundColor: accent.withValues(alpha: 0.12),
                foregroundColor: accent,
                dense: true,
              ),
              if (post.isPinned)
                AppBadge(
                  label: 'مثبت',
                  backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                  foregroundColor: AppColors.warning,
                  dense: true,
                ),
              AppBadge(label: _typeLabel(post.type), dense: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(post.content, style: Theme.of(context).textTheme.bodyMedium),
          if (post.attachmentName != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.appColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.appColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(post.attachmentName!)),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            post.createdAtLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          PostReactionsRow(
            reactions: post.reactions,
            commentCount: post.comments.length,
            onReact: () => ref
                .read(communityControllerProvider(subjectId).notifier)
                .reactToPost(post.id),
            onCommentsTap: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (context) =>
                    CommentsSheet(subjectId: subjectId, post: post),
              );
            },
          ),
        ],
      ),
    );
  }
}

Color _postColor(CommunityPostType type) {
  return switch (type) {
    CommunityPostType.announcement => AppColors.error,
    CommunityPostType.question => AppColors.warning,
    CommunityPostType.discussion => AppColors.primary,
  };
}

String _typeLabel(CommunityPostType type) {
  return switch (type) {
    CommunityPostType.announcement => 'إعلان',
    CommunityPostType.question => 'سؤال',
    CommunityPostType.discussion => 'نقاش',
  };
}
