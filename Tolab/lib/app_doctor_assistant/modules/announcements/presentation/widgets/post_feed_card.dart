import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../../../../../app_admin/shared/widgets/status_badge.dart';
import '../models/announcements_workspace_models.dart';

class PostFeedCard extends StatelessWidget {
  const PostFeedCard({
    super.key,
    required this.item,
    required this.onOpenThread,
    required this.onTogglePin,
  });

  final AnnouncementFeedItem item;
  final VoidCallback onOpenThread;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final accent = item.isUrgent ? const Color(0xFFDC2626) : const Color(0xFF2563EB);

    return AppCard(
      interactive: true,
      onTap: onOpenThread,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusBadge(item.subjectCode),
              StatusBadge(item.type),
              StatusBadge(item.statusLabel),
              if (item.isUrgent) StatusBadge('Urgent'),
              if (item.isPinned) StatusBadge('Pinned'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${item.authorName} • ${item.subjectName} • ${_timestamp(item.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (item.attachmentLabel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.attachmentLabel!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: accent),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 18, color: accent),
              const SizedBox(width: AppSpacing.xs),
              Text('${item.commentsCount} comments'),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.favorite_border_rounded, size: 18, color: accent),
              const SizedBox(width: AppSpacing.xs),
              Text('${item.reactionsCount} reactions'),
              const Spacer(),
              TextButton(
                onPressed: onTogglePin,
                child: Text(item.isPinned ? 'Unpin' : 'Pin'),
              ),
              FilledButton.tonal(
                onPressed: onOpenThread,
                child: const Text('Open thread'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _timestamp(DateTime value) {
  final difference = DateTime(2026, 4, 23, 12).difference(value);
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours}h ago';
  }
  return '${difference.inDays}d ago';
}
