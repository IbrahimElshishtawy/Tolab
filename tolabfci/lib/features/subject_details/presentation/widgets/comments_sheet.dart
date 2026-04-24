import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../providers/community_providers.dart';
import 'add_comment_field.dart';

class CommentsSheet extends ConsumerWidget {
  const CommentsSheet({super.key, required this.subjectId, required this.post});

  final String subjectId;
  final CommunityPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التعليقات', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (post.comments.isEmpty)
            const Text('لا توجد تعليقات بعد. ابدأ النقاش.')
          else
            ...post.comments.map(
              (comment) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(comment.content),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      comment.createdAtLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          AddCommentField(
            onSubmit: (value) async {
              await ref
                  .read(communityControllerProvider(subjectId).notifier)
                  .addComment(postId: post.id, content: value);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
