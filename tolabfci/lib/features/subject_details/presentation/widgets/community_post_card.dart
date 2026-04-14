import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../../core/theme/app_spacing.dart';
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.authorName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(post.authorRole, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Text(post.content),
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
