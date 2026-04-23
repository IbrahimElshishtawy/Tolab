import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/shared/widgets/premium_button.dart';
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

class SubjectGroupPage extends StatelessWidget {
  const SubjectGroupPage({super.key, required this.subjectId});

  final int subjectId;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _GroupVm>(
      onInit: (store) => store.dispatch(LoadSubjectGroupAction(subjectId)),
      converter: (store) => _GroupVm.fromStore(store, subjectId),
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
            PremiumButton(
              label: 'New post',
              icon: Icons.post_add_rounded,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AddPostPage(subjectId: subjectId),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(group.summary, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.md),
        LatestPostsSection(
          posts: group.posts,
          actionsBuilder: (context, post) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AddPostPage(
                        subjectId: subjectId,
                        post: post,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit post',
                ),
                IconButton(
                  onPressed: () => vm.store.dispatch(
                    TogglePinnedPostAction(
                      subjectId: subjectId,
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
                ),
                IconButton(
                  onPressed: () => vm.store.dispatch(
                    DeleteGroupPostAction(
                      subjectId: subjectId,
                      postId: post.id,
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  tooltip: 'Delete post',
                ),
              ],
            );
          },
        ),
      ],
    );
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
