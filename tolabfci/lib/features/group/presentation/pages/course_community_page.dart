import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../subject_details/presentation/providers/community_providers.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';
import '../widgets/community_chat_section.dart';
import '../widgets/community_posts_section.dart';

class CourseCommunityPage extends ConsumerStatefulWidget {
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
  ConsumerState<CourseCommunityPage> createState() =>
      _CourseCommunityPageState();
}

class _CourseCommunityPageState extends ConsumerState<CourseCommunityPage> {
  final GlobalKey _chatSectionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(communityControllerProvider(widget.subjectId));
    final subjectAsync = ref.watch(subjectByIdProvider(widget.subjectId));
    final notifications =
        ref.watch(notificationsStreamProvider).value ?? const [];
    final unreadCount = notifications.where((item) {
      return !item.isRead &&
          item.pathParameters['subjectId'] == widget.subjectId &&
          item.category.contains('الجروب');
    }).length;

    final body = postsAsync.when(
      data: (posts) {
        final subjectName = subjectAsync.value?.name;

        final header = AppCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          backgroundColor: context.appColors.surfaceElevated,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              final title = Text(
                subjectName == null
                    ? 'مجتمع المقرر / Course Community'
                    : 'مجتمع $subjectName',
                style: Theme.of(context).textTheme.titleLarge,
              );
              final action = AppButton(
                label: 'دخول الشات الجماعي',
                onPressed: _openGroupChat,
                icon: Icons.chat_bubble_outline_rounded,
                isExpanded: compact,
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: AppSpacing.sm),
                    action,
                  ],
                );
              }

              return Row(
                textDirection: TextDirection.ltr,
                children: [
                  Expanded(
                    child: Directionality(
                      textDirection: Directionality.of(context),
                      child: title,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  action,
                ],
              );
            },
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
              subjectId: widget.subjectId,
              posts: posts,
              subjectName: subjectName,
            );
            final chatSection = KeyedSubtree(
              key: _chatSectionKey,
              child: CommunityChatSection(
                subjectId: widget.subjectId,
                unreadCount: unreadCount,
                height: chatHeight,
              ),
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

        if (widget.usePageScroll) {
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

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('مجتمع المقرر')),
      body: SafeArea(child: AdaptivePageContainer(child: body)),
    );
  }

  void _openGroupChat() {
    final chatContext = _chatSectionKey.currentContext;
    if (chatContext == null) {
      return;
    }
    Scrollable.ensureVisible(
      chatContext,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }
}
