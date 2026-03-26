import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/notifications_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NotificationsState>(
      onInit: (store) => store.dispatch(LoadNotificationsAction()),
      converter: (store) => store.state.notificationsState,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Notifications',
              subtitle:
                  'Compose broadcasts, inspect history, and keep read-state visibility across admin operations.',
              breadcrumbs: ['Admin', 'Notifications'],
              actions: [
                PremiumButton(label: 'Broadcast', icon: Icons.campaign_rounded),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: AsyncStateView(
                status: state.status,
                errorMessage: state.errorMessage,
                onRetry: () => StoreProvider.of<AppState>(
                  context,
                ).dispatch(LoadNotificationsAction()),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppCard(
                        child: ListView.separated(
                          itemCount: state.items.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                child: Icon(
                                  item.isRead
                                      ? Icons.notifications_none_rounded
                                      : Icons.notifications_active_rounded,
                                ),
                              ),
                              title: Text(item.title),
                              subtitle: Text(
                                '${item.body}\n${item.createdAtLabel}',
                              ),
                              trailing: StatusBadge(
                                item.isRead ? 'Read' : item.category,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Broadcast studio',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const TextField(
                              decoration: InputDecoration(
                                labelText: 'Audience',
                                hintText:
                                    'All students / a section / a department',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const TextField(
                              decoration: InputDecoration(labelText: 'Title'),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const TextField(
                              maxLines: 5,
                              decoration: InputDecoration(labelText: 'Message'),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {},
                                child: const Text('Queue notification'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
