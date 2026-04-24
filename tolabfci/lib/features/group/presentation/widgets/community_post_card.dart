import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../subject_details/presentation/providers/community_providers.dart';

class CommunityPostCard extends ConsumerWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    required this.subjectId,
    this.subjectName,
  });

  final CommunityPost post;
  final String subjectId;
  final String? subjectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _postColor(post.type);
    final title = post.title ?? _deriveTitle(post.content);
    final attachments = [
      ...post.attachments,
      if (post.attachmentName != null) post.attachmentName!,
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_postIcon(post.type), color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        AppBadge(
                          label: post.authorRole,
                          backgroundColor: accent.withValues(alpha: 0.12),
                          foregroundColor: accent,
                        ),
                        if (subjectName != null) AppBadge(label: subjectName!),
                        if (post.isPinned)
                          AppBadge(
                            label: 'مثبت',
                            backgroundColor: AppColors.warning.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: AppColors.warning,
                          ),
                        if (post.isImportant)
                          AppBadge(
                            label: 'مهم',
                            backgroundColor: AppColors.support.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: AppColors.support,
                          ),
                        if (post.isUrgent)
                          AppBadge(
                            label: 'عاجل',
                            backgroundColor: AppColors.error.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: AppColors.error,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                post.createdAtLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            post.preview ?? post.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: attachments
                  .toSet()
                  .map(
                    (attachment) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.attach_file_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(attachment),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => ref
                    .read(communityControllerProvider(subjectId).notifier)
                    .reactToPost(post.id),
                icon: const Icon(Icons.thumb_up_alt_outlined),
                label: Text('${post.reactions} تفاعل'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showCommentComposer(context, ref),
                icon: const Icon(Icons.mode_comment_outlined),
                label: Text('${post.comments.length} تعليق'),
              ),
            ],
          ),
          if (post.comments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...post.comments
                .take(2)
                .map(
                  (comment) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.appColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.appColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.authorName,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(comment.content),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  void _showCommentComposer(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أضف تعليقًا', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'التعليق',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () async {
                final content = controller.text.trim();
                if (content.isEmpty) {
                  return;
                }
                await ref
                    .read(communityControllerProvider(subjectId).notifier)
                    .addComment(postId: post.id, content: content);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('إرسال التعليق'),
            ),
          ],
        ),
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

IconData _postIcon(CommunityPostType type) {
  return switch (type) {
    CommunityPostType.announcement => Icons.push_pin_outlined,
    CommunityPostType.question => Icons.help_outline_rounded,
    CommunityPostType.discussion => Icons.forum_outlined,
  };
}

String _deriveTitle(String content) {
  final words = content.split(' ');
  if (words.length <= 5) {
    return content;
  }
  return words.take(5).join(' ');
}
