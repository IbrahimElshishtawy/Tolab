import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/state/async_state.dart';
import '../../../core/widgets/state_views.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/groups_actions.dart';
import '../state/groups_state.dart';
import 'add_post_page.dart';
import 'widgets/latest_posts_section.dart';

class SubjectGroupPage extends StatefulWidget {
  const SubjectGroupPage({super.key, required this.subjectId});

  final int subjectId;

  @override
  State<SubjectGroupPage> createState() => _SubjectGroupPageState();
}

class _SubjectGroupPageState extends State<SubjectGroupPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _GroupVm>(
      onInit: (store) => store.dispatch(LoadSubjectGroupAction(widget.subjectId)),
      converter: (store) => _GroupVm.fromStore(store, widget.subjectId),
      builder: (context, vm) {
        if (vm.user == null) {
          return const SizedBox.shrink();
        }

        return DoctorAssistantShell(
          user: vm.user!,
          activeRoute: AppRoutes.subjects,
          unreadNotifications: 0,
          child: DoctorAssistantPageScaffold(
            title: 'Subject Group',
            subtitle:
                'Posts, comments, and activity feed stay aligned to the academic teaching context.',
            breadcrumbs: const ['Workspace', 'Subjects', 'Group'],
            scrollable: false,
            child: _buildBody(context, vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, _GroupVm vm) {
    final group = vm.state.data;
    if (vm.state.status == ViewStatus.loading && group == null) {
      return const LoadingStateView(lines: 3);
    }
    if (vm.state.status == ViewStatus.failure && group == null) {
      return ErrorStateView(
        message: vm.state.error ?? 'Failed to load group feed.',
        onRetry: vm.reload,
      );
    }
    if (group == null) {
      return const EmptyStateView(
        title: 'No group feed yet',
        message: 'Group activity will appear here once posts and comments are available.',
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  _Metric(label: 'Posts', value: '${group.postsCount}'),
                  _Metric(label: 'Comments', value: '${group.commentsCount}'),
                  _Metric(label: 'Engagement', value: '${group.engagementCount}'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(group.summary, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: SingleChildScrollView(
            child: LatestPostsSection(
              posts: group.posts,
              currentUser: vm.user,
              asChat: true,
              actionsBuilder: (context, post) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AddPostPage(
                            subjectId: widget.subjectId,
                            post: post,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Edit post',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => vm.store.dispatch(
                        TogglePinnedPostAction(
                          subjectId: widget.subjectId,
                          postId: post.id,
                        ),
                      ),
                      icon: Icon(
                        post.isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        size: 18,
                      ),
                      tooltip: 'Pin post',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => vm.store.dispatch(
                        DeleteGroupPostAction(
                          subjectId: widget.subjectId,
                          postId: post.id,
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      tooltip: 'Delete post',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A3942) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        color: isDark ? const Color(0xFF8696A0) : const Color(0xFF667781),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: Localizations.localeOf(context).languageCode == 'ar'
                                ? 'اكتب رسالة...'
                                : 'Type a message...',
                            hintStyle: TextStyle(
                              color: isDark ? const Color(0xFF8696A0) : const Color(0xFF667781),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: (_) => _sendMessage(vm),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.attach_file_rounded),
                        onPressed: () => context.go(AppRoutes.addSubjectPost(widget.subjectId)),
                        color: isDark ? const Color(0xFF8696A0) : const Color(0xFF667781),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _sendMessage(vm),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00A884), // WhatsApp green
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage(_GroupVm vm) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    vm.store.dispatch(
      SaveGroupPostAction(
        subjectId: widget.subjectId,
        payload: <String, dynamic>{
          'title': '',
          'content': text,
          'post_type': 'post',
          'priority': 'normal',
          'is_pinned': false,
          'attachment_label': '',
        },
      ),
    );

    _messageController.clear();
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _GroupVm {
  const _GroupVm({
    required this.user,
    required this.state,
    required this.reload,
    required this.store,
  });

  final dynamic user;
  final GroupsState state;
  final VoidCallback reload;
  final Store<DoctorAssistantAppState> store;

  factory _GroupVm.fromStore(Store<DoctorAssistantAppState> store, int subjectId) {
    return _GroupVm(
      user: getCurrentUser(store.state),
      state: store.state.groupsState,
      reload: () => store.dispatch(LoadSubjectGroupAction(subjectId)),
      store: store,
    );
  }
}
