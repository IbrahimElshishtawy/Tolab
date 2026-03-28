import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../state/app_state.dart';
import '../models/moderation_models.dart';
import '../state/moderation_state.dart';
import 'screens/analytics_screen.dart';
import 'screens/comments_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/posts_screen.dart';
import 'screens/reports_screen.dart';
import 'widgets/moderation_overview_strip.dart';
import 'widgets/moderation_preview_dialog.dart';

class ModerationScreen extends StatelessWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ModerationShellViewModel>(
      onInit: (store) {
        store.dispatch(const LoadModerationDashboardRequestedAction());
        store.dispatch(const StartModerationNotificationsPollingAction());
      },
      onDispose: (store) =>
          store.dispatch(const StopModerationNotificationsPollingAction()),
      converter: (store) {
        final state = store.state.moderationState;
        return _ModerationShellViewModel(
          state: state,
          metrics: selectModerationMetrics(store.state),
          unreadNotifications: selectUnreadNotifications(store.state),
        );
      },
      builder: (context, vm) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Moderation',
              subtitle:
                  'University-wide safety operations for groups, posts, comments, reports, messaging, and moderator permissions.',
              breadcrumbs: const ['Admin', 'Safety', 'Moderation'],
              actions: [
                PremiumButton(
                  label: 'Refresh',
                  icon: Icons.refresh_rounded,
                  isSecondary: true,
                  onPressed: () => StoreProvider.of<AppState>(context).dispatch(
                    const LoadModerationDashboardRequestedAction(silent: true),
                  ),
                ),
                PremiumButton(
                  label: 'Assign moderators',
                  icon: Icons.admin_panel_settings_outlined,
                  onPressed: () => StoreProvider.of<AppState>(context).dispatch(
                    const ModerationTabChangedAction(
                      ModerationWorkspaceTab.permissions,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (vm.state.feedbackMessage != null &&
                vm.state.feedbackMessage!.isNotEmpty) ...[
              ModerationNoticeBanner(
                message: vm.state.feedbackMessage!,
                isFallback: vm.state.isUsingFallbackData,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            ModerationOverviewStrip(
              metrics: vm.metrics,
              notifications: vm.unreadNotifications,
            ),
            const SizedBox(height: AppSpacing.md),
            _TabBarStrip(activeTab: vm.state.activeTab),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AsyncStateView(
                status: vm.state.status,
                errorMessage: vm.state.errorMessage,
                onRetry: () => StoreProvider.of<AppState>(context).dispatch(
                  const LoadModerationDashboardRequestedAction(),
                ),
                isEmpty: vm.state.groups.isEmpty &&
                    vm.state.posts.isEmpty &&
                    vm.state.comments.isEmpty &&
                    vm.state.reports.isEmpty,
                emptyTitle: 'No moderation data yet',
                emptySubtitle:
                    'Connect the Laravel moderation endpoints or wait for new reports to arrive.',
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: KeyedSubtree(
                    key: ValueKey(vm.state.activeTab),
                    child: _screenFor(vm.state.activeTab),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _screenFor(ModerationWorkspaceTab tab) {
    return switch (tab) {
      ModerationWorkspaceTab.groups => const ModerationGroupsScreen(),
      ModerationWorkspaceTab.posts => const ModerationPostsScreen(),
      ModerationWorkspaceTab.comments => const ModerationCommentsScreen(),
      ModerationWorkspaceTab.messages => const ModerationMessagesScreen(),
      ModerationWorkspaceTab.reports => const ModerationReportsScreen(),
      ModerationWorkspaceTab.analytics => const ModerationAnalyticsScreen(),
      ModerationWorkspaceTab.permissions =>
        const ModerationPermissionsScreen(),
    };
  }
}

class _TabBarStrip extends StatelessWidget {
  const _TabBarStrip({required this.activeTab});

  final ModerationWorkspaceTab activeTab;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ModerationWorkspaceTab.values
            .map(
              (tab) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  avatar: Icon(tab.icon, size: 18),
                  label: Text(tab.label),
                  selected: tab == activeTab,
                  onSelected: (_) => StoreProvider.of<AppState>(context).dispatch(
                    ModerationTabChangedAction(tab),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _ModerationShellViewModel {
  const _ModerationShellViewModel({
    required this.state,
    required this.metrics,
    required this.unreadNotifications,
  });

  final ModerationState state;
  final ModerationMetrics metrics;
  final List<ModerationNotificationItem> unreadNotifications;
}
