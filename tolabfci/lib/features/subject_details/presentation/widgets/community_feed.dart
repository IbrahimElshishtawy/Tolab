import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
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
      data: (posts) {
        if (posts.isEmpty) {
          return const EmptyStateWidget(
            title: 'لا توجد منشورات بعد',
            subtitle: 'ستظهر إعلانات الدكتور ومنشورات الطلبة هنا.',
          );
        }

        final pinned = posts.where((post) => post.isPinned).toList();
        final regular = posts.where((post) => !post.isPinned).toList();

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            if (pinned.isNotEmpty) ...[
              const _FeedHeader(
                title: 'إعلانات مثبتة',
                subtitle: 'أهم الإعلانات الأكاديمية الجاهزة للمتابعة الآن.',
              ),
              const SizedBox(height: AppSpacing.md),
              ...pinned.map(
                (post) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: CommunityPostCard(post: post, subjectId: subjectId),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            const _FeedHeader(
              title: 'آخر النشاط',
              subtitle:
                  'منشورات الدكتور، الإعلانات، وأسئلة الطلبة داخل الجروب.',
            ),
            const SizedBox(height: AppSpacing.md),
            ...regular.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: CommunityPostCard(post: post, subjectId: subjectId),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: LoadingWidget()),
      error: (error, _) => Text(error.toString()),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
