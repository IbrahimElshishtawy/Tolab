import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/localization/app_localization.dart';
import '../../../subject_details/presentation/providers/community_providers.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';
import '../widgets/community_posts_section.dart';
import 'group_chat_page.dart';

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
                label: context.tr('دخول الشات الجماعي', 'Open Group Chat'),
                onPressed: () =>
                    _openGroupChat(context, subjectName: subjectName),
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

        final postsSection = CommunityPostsSection(
          subjectId: subjectId,
          posts: posts,
          subjectName: subjectName,
        );

        final children = <Widget>[
          header,
          const SizedBox(height: AppSpacing.md),
          postsSection,
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

  void _openGroupChat(BuildContext context, {String? subjectName}) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GroupChatPage(subjectId: subjectId, subjectName: subjectName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offset = Tween<Offset>(
            begin: const Offset(0.12, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
      ),
    );
  }
}
