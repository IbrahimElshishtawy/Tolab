import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../subject_details/presentation/providers/community_providers.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';
import '../widgets/community_chat_section.dart';
import '../widgets/community_posts_section.dart';

class CourseCommunityPage extends ConsumerWidget {
  const CourseCommunityPage({
    super.key,
    required this.subjectId,
    this.embedded = false,
    this.usePageScroll = false,
  });

  final String subjectId;
  final bool embedded;
  final bool usePageScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityControllerProvider(subjectId));
    final subjectAsync = ref.watch(subjectByIdProvider(subjectId));
    final notifications =
        ref.watch(notificationsStreamProvider).value ?? const [];
    final unreadCount = notifications.where((item) {
      return !item.isRead &&
          item.pathParameters['subjectId'] == subjectId &&
          item.category.contains('الجروب');
    }).length;

    final body = postsAsync.when(
      data: (posts) {
        final pinnedCount = posts.where((post) => post.isPinned).length;
        final attachmentsCount = posts.fold<int>(
          0,
          (count, post) =>
              count +
              post.attachments.length +
              (post.attachmentName == null ? 0 : 1),
        );
        final subjectName = subjectAsync.value?.name;

        final header = AppCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          backgroundColor: context.appColors.surfaceElevated,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                subjectName == null
                    ? 'مجتمع المقرر / Course Community'
                    : 'مجتمع $subjectName',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppBadge(label: '${posts.length} منشور', dense: true),
              AppBadge(
                label: '$pinnedCount مثبت',
                backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                foregroundColor: AppColors.warning,
                dense: true,
              ),
              AppBadge(
                label: '$attachmentsCount مرفق',
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                foregroundColor: AppColors.primary,
                dense: true,
              ),
            ],
          ),
        );

        final content = LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth > 1100;
            final tablet = constraints.maxWidth >= 700;
            final chatHeight = desktop
                ? 620.0
                : tablet
                ? 520.0
                : 500.0;
            final postsSection = CommunityPostsSection(
              subjectId: subjectId,
              posts: posts,
              subjectName: subjectName,
            );
            final chatSection = CommunityChatSection(
              subjectId: subjectId,
              unreadCount: unreadCount,
              height: chatHeight,
            );

            if (!desktop) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  postsSection,
                  const SizedBox(height: AppSpacing.md),
                  chatSection,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: postsSection),
                const SizedBox(width: AppSpacing.md),
                SizedBox(width: 420, child: chatSection),
              ],
            );
          },
        );

        final children = <Widget>[
          header,
          const SizedBox(height: AppSpacing.md),
          content,
        ];

        if (usePageScroll) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        }

        return ListView(children: children);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );

    if (embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('مجتمع المقرر')),
      body: SafeArea(child: AdaptivePageContainer(child: body)),
    );
  }
}
