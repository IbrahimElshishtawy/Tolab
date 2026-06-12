import 'package:flutter/material.dart';

import '../../../../core/models/session_user.dart';
import '../../models/group_models.dart';

class LatestPostsSection extends StatelessWidget {
  const LatestPostsSection({
    super.key,
    required this.posts,
    this.showComments = true,
    this.actionsBuilder,
    this.currentUser,
    this.asChat = false,
  });

  final List<GroupPostModel> posts;
  final bool showComments;
  final Widget Function(BuildContext context, GroupPostModel post)? actionsBuilder;
  final SessionUser? currentUser;
  final bool asChat;

  @override
  Widget build(BuildContext context) {
    if (asChat) {
      return _buildChatLayout(context);
    } else {
      return _buildCardLayout(context);
    }
  }

  Widget _buildCardLayout(BuildContext context) {
    return Column(
      children: [
        for (final post in posts)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              padding: const EdgeInsets.all(16),
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
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Text(
                                  post.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (post.isPinned)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.push_pin_rounded, size: 12),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Pinned',
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: post.priority == 'high' 
                                        ? Colors.orange.withValues(alpha: 0.15)
                                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    post.priority,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: post.priority == 'high' ? Colors.orange : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
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
                            const SizedBox(height: 4),
                            actionsBuilder!(context, post),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if ((post.attachmentLabel ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.attach_file_rounded, size: 16),
                          const SizedBox(width: 4),
                          Text(post.attachmentLabel!),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _EngagementChip(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: '${post.commentsCount} comments',
                      ),
                      const SizedBox(width: 8),
                      _EngagementChip(
                        icon: Icons.bolt_rounded,
                        label: '${post.reactionsCount} reactions',
                      ),
                    ],
                  ),
                  if (showComments && post.comments.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    for (final comment in post.comments.take(2))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${comment.authorName} · ${comment.authorRole}',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
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

  Widget _buildChatLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B141A) : const Color(0xFFEFEAE2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          if (posts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No messages yet',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
          for (final post in posts) ...[
            // RENDER POST
            Builder(
              builder: (context) {
                final isMe = currentUser != null &&
                    (post.authorName.toLowerCase().trim() == currentUser!.fullName.toLowerCase().trim() ||
                        post.authorRole.toLowerCase() == 'doctor');

                return _ChatBubble(
                  isMe: isMe,
                  timestamp: _timeLabel(post.createdAt),
                  senderName: post.authorName,
                  senderRole: post.authorRole,
                  isPinned: post.isPinned,
                  priority: post.priority,
                  actions: actionsBuilder != null ? actionsBuilder!(context, post) : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (post.title.isNotEmpty) ...[
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        post.content,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if ((post.attachmentLabel ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _WhatsAppFileAttachment(label: post.attachmentLabel!),
                      ],
                    ],
                  ),
                );
              },
            ),

            // RENDER COMMENTS
            if (showComments && post.comments.isNotEmpty)
              for (final comment in post.comments)
                Builder(
                  builder: (context) {
                    final isMe = currentUser != null &&
                        comment.authorName.toLowerCase().trim() == currentUser!.fullName.toLowerCase().trim();

                    return _ChatBubble(
                      isMe: isMe,
                      timestamp: _timeLabel(comment.createdAt),
                      senderName: comment.authorName,
                      senderRole: comment.authorRole,
                      quotedWidget: _QuotedMessage(
                        authorName: post.authorName,
                        content: post.title.isNotEmpty ? post.title : post.content,
                      ),
                      child: Text(
                        comment.message,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  },
                ),
          ],
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.child,
    required this.isMe,
    required this.timestamp,
    this.senderName,
    this.senderRole,
    this.quotedWidget,
    this.isPinned = false,
    this.priority,
    this.actions,
  });

  final Widget child;
  final bool isMe;
  final String timestamp;
  final String? senderName;
  final String? senderRole;
  final Widget? quotedWidget;
  final bool isPinned;
  final String? priority;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMe
        ? (isDark ? const Color(0xFF005C4B) : const Color(0xFFD9FDD3))
        : (isDark ? const Color(0xFF202C33) : const Color(0xFFFFFFFF));

    final nameColor = isMe
        ? (isDark ? const Color(0xFF4AC3A1) : const Color(0xFF005C4B))
        : (isDark ? const Color(0xFF53BDEB) : const Color(0xFF008069));

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isMe && senderName != null)
                  Expanded(
                    child: Text(
                      '$senderName (${senderRole ?? ''})',
                      style: TextStyle(
                        color: nameColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else if (isMe)
                  const Expanded(
                    child: Text(
                      'You',
                      style: TextStyle(
                        color: Color(0xFF53BDEB),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPinned)
                      const Icon(
                        Icons.push_pin_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                    if (priority == 'high') ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: Colors.orange,
                      ),
                    ],
                    if (actions != null) ...[
                      const SizedBox(width: 4),
                      actions!,
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),

            if (quotedWidget != null) ...[
              quotedWidget!,
              const SizedBox(height: 4),
            ],

            child,

            const SizedBox(height: 4),

            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timestamp,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotedMessage extends StatelessWidget {
  const _QuotedMessage({
    required this.authorName,
    required this.content,
  });

  final String authorName;
  final String content;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(
            color: isDark ? const Color(0xFF00A884) : const Color(0xFF008069),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            authorName,
            style: TextStyle(
              color: isDark ? const Color(0xFF00A884) : const Color(0xFF008069),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppFileAttachment extends StatelessWidget {
  const _WhatsAppFileAttachment({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxColor = isDark ? const Color(0xFF111B21) : const Color(0xFFF0F2F5);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.insert_drive_file_rounded,
            color: Color(0xFF707A80),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Document · PDF',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_downward_rounded,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
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
        horizontal: 8,
        vertical: 4,
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
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

String _timeLabel(DateTime createdAt) {
  final difference = DateTime(2026, 6, 12, 1).difference(createdAt);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes.abs()}m';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours.abs()}h';
  }
  return '${difference.inDays.abs()}d';
}
