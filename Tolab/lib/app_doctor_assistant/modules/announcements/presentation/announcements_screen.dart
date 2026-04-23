import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../presentation/widgets/workspace/faculty_quick_actions_bar.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import 'models/announcements_workspace_models.dart';
import 'widgets/create_post_sheet.dart';
import 'widgets/group_activity_section.dart';
import 'widgets/post_feed_card.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  AnnouncementFeedFilter _filter = AnnouncementFeedFilter.all;
  final List<AnnouncementComposerDraft> _drafts = <AnnouncementComposerDraft>[];
  final Map<int, List<AnnouncementCommentItem>> _localComments =
      <int, List<AnnouncementCommentItem>>{};
  int _nextDraftId = 9000;
  int _nextCommentId = 30000;

  void _openComposer(
    BuildContext context,
    AnnouncementsWorkspaceData workspace,
    DoctorAssistantMockRepository repository,
    SessionUser user,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return CreatePostSheet(
          subjects: workspace.subjects,
          onSubmit: (result) {
            if (result.saveAsDraft) {
              setState(() {
                _drafts.insert(
                  0,
                  AnnouncementComposerDraft(
                    id: _nextDraftId++,
                    subjectId: result.subjectId,
                    subjectCode: result.subjectCode,
                    subjectName: result.subjectName,
                    title: result.title,
                    content: result.content,
                    type: result.type,
                    isPinned: result.isPinned,
                    isUrgent: result.isUrgent,
                    attachmentLabel: result.attachmentLabel,
                  ),
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Draft saved to the local academic feed.')),
              );
              return;
            }

            repository.saveGroupPost(result.subjectId, <String, dynamic>{
              'title': result.title,
              'content': result.content,
              'post_type': result.type.toLowerCase().replaceAll(' ', '_'),
              'priority': result.isUrgent ? 'urgent' : 'normal',
              'is_pinned': result.isPinned,
              'attachment_label': result.attachmentLabel,
            }, user);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post published to the academic feed.')),
              );
              setState(() {});
            }
          },
        );
      },
    );
  }

  void _openThread(
    BuildContext context,
    AnnouncementFeedItem item,
  ) {
    final commentController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final comments = [
          ...item.comments,
          ...(_localComments[item.id] ?? const <AnnouncementCommentItem>[]),
        ];
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${item.subjectCode} • ${item.authorName} • ${item.type}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(item.content, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Comments & replies', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    if (comments.isEmpty)
                      const DoctorAssistantEmptyState(
                        title: 'Start the discussion',
                        subtitle:
                            'No comments yet. Add the first clarification, reply, or student follow-up note.',
                      )
                    else
                      Column(
                        children: comments
                            .map(
                              (comment) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: DoctorAssistantItemCard(
                                  icon: Icons.comment_rounded,
                                  title: comment.authorName,
                                  subtitle: '${comment.authorRole} • ${_threadTime(comment.createdAt)}',
                                  meta: comment.message,
                                  statusLabel: comment.authorRole,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: commentController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Add comment / reply',
                        hintText: 'Use @mentions if needed, for example @Eng. Mariam please confirm.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: () {
                        final text = commentController.text.trim();
                        if (text.isEmpty) {
                          return;
                        }
                        final next = AnnouncementCommentItem(
                          id: _nextCommentId++,
                          authorName: 'You',
                          authorRole: 'staff',
                          message: text,
                          createdAt: DateTime(2026, 4, 23, 12, 0),
                        );
                        setState(() {
                          _localComments.update(
                            item.id,
                            (value) => [...value, next],
                            ifAbsent: () => [next],
                          );
                        });
                        setSheetState(() {});
                        commentController.clear();
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Post reply'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(commentController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final repository = DoctorAssistantMockRepository.instance;
        final workspace = buildAnnouncementsWorkspace(
          repository,
          user,
          drafts: _drafts,
          localComments: _localComments,
        );
        final filteredFeed = filterFeedItems(workspace.feed, _filter);

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.announcements,
          unreadNotifications: repository.unreadNotificationsFor(user),
          child: DoctorAssistantPageScaffold(
            title: 'Announcements / group activity',
            subtitle:
                'Academic social feed for publishing updates, tracking threads, and keeping the teaching team aligned.',
            breadcrumbs: const ['Workspace', 'Announcements'],
            actions: [
              FilledButton.icon(
                onPressed: () => _openComposer(context, workspace, repository, user),
                icon: const Icon(Icons.add_comment_rounded),
                label: const Text('Create post'),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FacultyQuickActionsBar(user: user),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: AnnouncementFeedFilter.values
                      .map(
                        (filter) => ChoiceChip(
                          label: Text(filter.label),
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 1180;
                    final feedSection = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (filteredFeed.isEmpty)
                          const DoctorAssistantEmptyState(
                            title: 'Start your first announcement',
                            subtitle:
                                'No items match the current filter. Publish a course update or save a draft to begin the feed.',
                          )
                        else
                          Column(
                            children: filteredFeed
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                    child: PostFeedCard(
                                      item: item,
                                      onOpenThread: () => _openThread(context, item),
                                      onTogglePin: () {
                                        if (item.isDraft) {
                                          setState(() {
                                            final draftIndex = _drafts.indexWhere(
                                              (draft) => draft.id == item.id,
                                            );
                                            if (draftIndex == -1) {
                                              return;
                                            }
                                            final draft = _drafts[draftIndex];
                                            _drafts[draftIndex] = AnnouncementComposerDraft(
                                              id: draft.id,
                                              subjectId: draft.subjectId,
                                              subjectCode: draft.subjectCode,
                                              subjectName: draft.subjectName,
                                              title: draft.title,
                                              content: draft.content,
                                              type: draft.type,
                                              isPinned: !draft.isPinned,
                                              isUrgent: draft.isUrgent,
                                              attachmentLabel: draft.attachmentLabel,
                                            );
                                          });
                                          return;
                                        }
                                        repository.togglePinnedPost(item.id);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                      ],
                    );
                    final activitySection = GroupActivitySection(
                      activity: workspace.activity,
                      unresolvedThreads: workspace.unresolvedThreads,
                      studentQuestions: workspace.studentQuestions,
                    );

                    if (!isWide) {
                      return Column(
                        children: [
                          feedSection,
                          const SizedBox(height: AppSpacing.md),
                          activitySection,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: feedSection),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(flex: 4, child: activitySection),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _threadTime(DateTime value) {
  final diff = DateTime(2026, 4, 23, 12).difference(value);
  if (diff.inHours < 1) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inDays < 1) {
    return '${diff.inHours}h ago';
  }
  return '${diff.inDays}d ago';
}
