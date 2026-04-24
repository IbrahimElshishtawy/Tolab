import 'package:flutter/material.dart';

import '../../../../core/models/community_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import 'community_post_card.dart';

class CommunityPostsSection extends StatelessWidget {
  const CommunityPostsSection({
    super.key,
    required this.subjectId,
    required this.posts,
    this.subjectName,
  });

  final String subjectId;
  final List<CommunityPost> posts;
  final String? subjectName;

  @override
  Widget build(BuildContext context) {
    final pinned = posts.where((post) => post.isPinned).toList();
    final regular = posts.where((post) => !post.isPinned).toList();

    if (posts.isEmpty) {
      return const AppCard(
        child: Text(
          'لا توجد منشورات بعد. ستظهر الإعلانات والأسئلة هنا عند نشرها.',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pinned.isNotEmpty) ...[
          const _SectionTitle(
            title: 'منشورات مثبتة / Pinned posts',
            subtitle: 'الإعلانات المهمة والمرفقات التي يحتاجها الطالب سريعًا.',
          ),
          const SizedBox(height: AppSpacing.sm),
          ...pinned.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: CommunityPostCard(
                post: post,
                subjectId: subjectId,
                subjectName: subjectName,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        const _SectionTitle(
          title: 'آخر المنشورات / Latest posts',
          subtitle: 'أسئلة الطلبة، ردود الطاقم، التفاعلات، والتعليقات.',
        ),
        const SizedBox(height: AppSpacing.sm),
        ...regular.map(
          (post) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: CommunityPostCard(
              post: post,
              subjectId: subjectId,
              subjectName: subjectName,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
