import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/repositories/mock_notifications_repository.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: notificationsAsync.when(
          data: (notifications) => notifications.isEmpty
              ? const EmptyStateWidget(
                  title: 'No notifications',
                  subtitle: 'New alerts and updates will appear here.',
                )
              : ListView(
                  children: [
                    Text('Notifications', style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: AppSpacing.lg),
                    ...notifications.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: NotificationTile(
                          notification: item,
                          onMarkAsRead: () => ref
                              .read(notificationsRepositoryProvider)
                              .markAsRead(item.id),
                        ),
                      ),
                    ),
                  ],
                ),
          loading: () => const LoadingWidget(label: 'Loading notifications...'),
          error: (error, stackTrace) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}
