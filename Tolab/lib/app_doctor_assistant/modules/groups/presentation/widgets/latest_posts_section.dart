import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../../../../../app_admin/shared/widgets/status_badge.dart';
import '../../models/group_models.dart';

class LatestPostsSection extends StatelessWidget {
  const LatestPostsSection({
    super.key,
    required this.posts,
    this.showComments = true,
    this.actionsBuilder,
  });

  final List<GroupPostModel> posts;
  final bool showComments;
  final Widget Function(BuildContext context, GroupPostModel post)? actionsBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final post in posts)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                Text(
                                  post.title,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                if (post.isPinned)
                                  const StatusBadge('Pinned', icon: Icons.push_pin_rounded),
                                StatusBadge(post.priority),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${post.authorName} · ${post.authorRole}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _timeLabel(post.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (actionsBuilder != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            actionsBuilder!(context, post),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    post.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if ((post.attachmentLabel ?? '').isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.attach_file_rounded, size: 16),
                          const SizedBox(width: AppSpacing.xs),
                          Text(post.attachmentLabel!),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _EngagementChip(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: '${post.commentsCount} comments',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _EngagementChip(
                        icon: Icons.bolt_rounded,
                        label: '${post.reactionsCount} reactions',
                      ),
                    ],
                  ),
                  if (showComments && post.comments.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    for (final comment in post.comments.take(2))
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${comment.authorName} · ${comment.authorRole}',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(comment.message),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EngagementChip extends StatelessWidget {
  const _EngagementChip({
    required this.icon,
    required this.label,
  });

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
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

String _timeLabel(DateTime createdAt) {
  final difference = DateTime(2026, 4, 23, 12).difference(createdAt);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h';
  }
  return '${difference.inDays}d';
}
