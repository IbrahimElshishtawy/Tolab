import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/community_providers.dart';
import 'community_post_card.dart';

class CommunityFeed extends ConsumerWidget {
  const CommunityFeed({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityControllerProvider(subjectId));

    return postsAsync.when(
      data: (posts) => posts.isEmpty
          ? const EmptyStateWidget(
              title: 'No posts yet',
              subtitle:
                  'Subject announcements and student posts will appear here.',
            )
          : Column(
              children: posts
                  .map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CommunityPostCard(
                        post: post,
                        subjectId: subjectId,
                      ),
                    ),
                  )
                  .toList(),
            ),
      loading: () => const LoadingWidget(),
      error: (error, stackTrace) => Text(error.toString()),
    );
  }
}
