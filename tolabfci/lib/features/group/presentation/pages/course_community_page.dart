import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/models/community_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/repositories/mock_group_repository.dart';
import '../../../subject_details/presentation/providers/community_providers.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';
import '../widgets/community_posts_section.dart';
import 'group_chat_page.dart';

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
  final _postController = TextEditingController();
  String _filter = 'all';
  bool _isPosting = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(communityControllerProvider(widget.subjectId));
    final subjectAsync = ref.watch(subjectByIdProvider(widget.subjectId));
    final groupAsync = ref.watch(courseGroupProvider(widget.subjectId));

    final body = postsAsync.when(
      data: (posts) {
        final group = groupAsync.value;
        final subjectName = group?.courseName ?? subjectAsync.value?.name;
        final filteredPosts = _filteredPosts(posts);
        final postsSection = CommunityPostsSection(
          subjectId: widget.subjectId,
          posts: filteredPosts,
          subjectName: subjectName,
        );
        final desktopSplit = MediaQuery.sizeOf(context).width >= 1024;
        final contentSection = desktopSplit
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: postsSection),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 420,
                    child: GroupChatPage(
                      subjectId: widget.subjectId,
                      subjectName: subjectName,
                      embedded: true,
                    ),
                  ),
                ],
              )
            : postsSection;

        final children = <Widget>[
          _CourseGroupHeader(
            group: group,
            subjectName: subjectName,
            onOpenChat: () => _openGroupChat(context, subjectName: subjectName),
          ),
          const SizedBox(height: AppSpacing.md),
          if (group != null) ...[
            _GroupInfoCard(group: group),
            const SizedBox(height: AppSpacing.md),
          ],
          if (group?.pinnedAnnouncement != null) ...[
            _PinnedAnnouncementCard(text: group!.pinnedAnnouncement!),
            const SizedBox(height: AppSpacing.md),
          ],
          _CreatePostBox(
            controller: _postController,
            isPosting: _isPosting,
            onPost: _submitPost,
          ),
          const SizedBox(height: AppSpacing.md),
          _PostFilters(
            value: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: AppSpacing.md),
          contentSection,
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
      appBar: AppBar(title: Text(context.tr('مجتمع المقرر', 'Course Community'))),
      body: SafeArea(child: AdaptivePageContainer(child: body)),
    );
  }

  Future<void> _submitPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty || _isPosting) {
      return;
    }

    setState(() => _isPosting = true);
    try {
      await ref
          .read(communityControllerProvider(widget.subjectId).notifier)
          .createPost(content);
      if (!mounted) {
        return;
      }
      _postController.clear();
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  void _openGroupChat(BuildContext context, {String? subjectName}) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => GroupChatPage(
          subjectId: widget.subjectId,
          subjectName: subjectName,
        ),
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

  List<CommunityPost> _filteredPosts(List<CommunityPost> posts) {
    final filtered = [...posts];
    if (_filter == 'important') {
      filtered.removeWhere((post) => !post.isImportant && !post.isPinned);
    }
    if (_filter == 'oldest') {
      return filtered.reversed.toList();
    }
    return filtered;
  }
}

class _CourseGroupHeader extends StatelessWidget {
  const _CourseGroupHeader({
    required this.group,
    required this.subjectName,
    required this.onOpenChat,
  });

  final CourseGroup? group;
  final String? subjectName;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      backgroundColor: context.appColors.surfaceElevated,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          final title = Text(
            subjectName == null
                ? context.tr('مجتمع المقرر', 'Course Community')
                : context.tr('مجتمع $subjectName', '$subjectName Community'),
            style: Theme.of(context).textTheme.titleLarge,
          );
          final action = AppButton(
            label: context.tr('دخول الشات الجماعي', 'Open Group Chat'),
            onPressed: onOpenChat,
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
            children: [
              Expanded(child: title),
              const SizedBox(width: AppSpacing.md),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _GroupInfoCard extends StatelessWidget {
  const _GroupInfoCard({required this.group});

  final CourseGroup group;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: context.appColors.surfaceElevated,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          _GroupInfoChip(icon: Icons.school_outlined, label: group.doctorName),
          _GroupInfoChip(
            icon: Icons.co_present_outlined,
            label: group.assistantName,
          ),
          _GroupInfoChip(
            icon: Icons.groups_2_outlined,
            label: '${group.membersCount} members',
          ),
          _GroupInfoChip(
            icon: Icons.circle,
            label: '${group.onlineCount} online',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _GroupInfoChip extends StatelessWidget {
  const _GroupInfoChip({
    required this.icon,
    required this.label,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PinnedAnnouncementCard extends StatelessWidget {
  const _PinnedAnnouncementCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.warning.withValues(alpha: 0.10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.push_pin_outlined, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _CreatePostBox extends StatelessWidget {
  const _CreatePostBox({
    required this.controller,
    required this.isPosting,
    required this.onPost,
  });

  final TextEditingController controller;
  final bool isPosting;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('اكتب منشورا للمجموعة', 'Create a group post'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: context.tr(
                'اسأل سؤالا أو شارك تحديثا مع زملائك...',
                'Ask a question or share an update with classmates...',
              ),
              prefixIcon: const Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppButton(
              label: isPosting
                  ? context.tr('جاري النشر...', 'Posting...')
                  : context.tr('نشر', 'Post'),
              onPressed: isPosting ? null : onPost,
              icon: Icons.send_rounded,
              isExpanded: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostFilters extends StatelessWidget {
  const _PostFilters({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final entry in const {
            'all': 'All',
            'newest': 'Newest',
            'oldest': 'Oldest',
            'important': 'Important',
          }.entries)
            ChoiceChip(
              label: Text(entry.value),
              selected: value == entry.key,
              onSelected: (_) => onChanged(entry.key),
            ),
        ],
      ),
    );
  }
}
