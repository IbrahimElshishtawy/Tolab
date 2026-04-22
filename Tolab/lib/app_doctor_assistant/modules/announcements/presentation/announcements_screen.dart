import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/shared/widgets/status_badge.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final repository = DoctorAssistantMockRepository.instance;
        final announcements = repository.announcementsFor(user);
        final posts = repository.groupPostsFor(user);
        final threads = repository.messageThreadsFor(user);

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.announcements,
          unreadNotifications: repository.unreadNotificationsFor(user),
          child: DoctorAssistantPageScaffold(
            title: 'Announcements',
            subtitle:
                'Pinned announcements, course posts, and assistant message threads all stay interactive with local mock content.',
            breadcrumbs: const ['Workspace', 'Announcements'],
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 1100;
                final announcementsPanel = DoctorAssistantPanel(
                  title: 'Pinned and recent updates',
                  subtitle:
                      'These updates mirror what a backend-backed communication module would expose later.',
                  child: Column(
                    children: announcements.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: DoctorAssistantItemCard(
                          icon: item.isPinned
                              ? Icons.push_pin_rounded
                              : Icons.campaign_rounded,
                          title: item.title,
                          subtitle:
                              '${item.subjectCode} - ${item.audienceLabel} - ${item.authorName}',
                          meta: item.body,
                          statusLabel: item.priorityLabel,
                        ),
                      );
                    }).toList(growable: false),
                  ),
                );
                final collaborationPanel = DoctorAssistantPanel(
                  title: 'Group activity',
                  subtitle:
                      'Recent course posts and coordination threads for quick follow-up.',
                  child: Column(
                    children: [
                      ...posts.map(
                        (post) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: DoctorAssistantItemCard(
                            icon: Icons.forum_rounded,
                            title: post.authorName,
                            subtitle:
                                '${post.subjectCode} - ${post.reactionsCount} reactions',
                            meta: post.body,
                            statusLabel: '${post.commentsCount} comments',
                          ),
                        ),
                      ),
                      ...threads.map(
                        (thread) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: DoctorAssistantItemCard(
                            icon: Icons.mark_chat_unread_rounded,
                            title: thread.title,
                            subtitle: thread.participantsLabel,
                            meta: thread.lastMessage,
                            statusLabel: thread.unreadCount == 0
                                ? 'Read'
                                : '${thread.unreadCount} unread',
                            trailing: StatusBadge('Latest'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (!isWide) {
                  return Column(
                    children: [
                      announcementsPanel,
                      const SizedBox(height: AppSpacing.md),
                      collaborationPanel,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: announcementsPanel),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(flex: 5, child: collaborationPanel),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
