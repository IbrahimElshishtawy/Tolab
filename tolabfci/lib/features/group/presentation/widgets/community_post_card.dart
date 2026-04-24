import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../subject_details/presentation/providers/community_providers.dart';

class CommunityPostCard extends ConsumerWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    required this.subjectId,
    this.subjectName,
    this.compact = false,
  });

  final CommunityPost post;
  final String subjectId;
  final String? subjectName;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _postColor(post.type);
    final title = post.title ?? _deriveTitle(post.content);
    final attachments = {
      ...post.attachments,
      if (post.attachmentName != null) post.attachmentName!,
    }.toList();

    return AppCard(
      backgroundColor: context.appColors.surfaceElevated,
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_postIcon(post.type), color: accent, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        AppBadge(
                          label: post.authorRole,
                          backgroundColor: accent.withValues(alpha: 0.12),
                          foregroundColor: accent,
                          dense: true,
                        ),
                        if (subjectName != null)
                          AppBadge(label: subjectName!, dense: true),
                        if (post.isPinned)
                          AppBadge(
                            label: 'مثبت',
                            backgroundColor: AppColors.warning.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: AppColors.warning,
                            dense: true,
                          ),
                        if (post.isImportant)
                          AppBadge(
                            label: 'مهم',
                            backgroundColor: AppColors.support.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: AppColors.support,
                            dense: true,
                          ),
                        if (post.isUrgent)
                          AppBadge(
                            label: 'عاجل',
                            backgroundColor: AppColors.error.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: AppColors.error,
                            dense: true,
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
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            post.preview ?? post.content,
            maxLines: compact ? 2 : 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: attachments.map((attachment) {
                return AppBadge(
                  label: attachment,
                  foregroundColor: AppColors.primary,
                  dense: true,
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppButton(
                label: 'فتح المنشور',
                onPressed: () => _showCommentComposer(context, ref),
                icon: Icons.mode_comment_outlined,
                isExpanded: false,
                variant: AppButtonVariant.secondary,
              ),
              FilledButton.tonalIcon(
                onPressed: () => ref
                    .read(communityControllerProvider(subjectId).notifier)
                    .reactToPost(post.id),
                icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                label: Text('${post.reactions} تفاعل'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showCommentComposer(context, ref),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: Text('${post.comments.length} تعليق'),
              ),
            ],
          ),
          if (post.comments.isNotEmpty && !compact) ...[
            const SizedBox(height: AppSpacing.sm),
            ...post.comments
                .take(2)
                .map(
                  (comment) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: context.appColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.appColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppSpacing.xs,
                            children: [
                              Text(
                                comment.authorName,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              if (comment.authorRole != null)
                                AppBadge(
                                  label: comment.authorRole!,
                                  dense: true,
                                ),
                            ],
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
      showDragHandle: true,
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
            Text(
              'عرض التعليقات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (post.comments.isEmpty)
              Text(
                'لا توجد تعليقات بعد.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...post.comments.map(
                (comment) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text('${comment.authorName}: ${comment.content}'),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'التعليق',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'إرسال التعليق',
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
              icon: Icons.send_rounded,
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
