import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../shared/models/moderation_models.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/management_page.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/moderation_state.dart';

class ModerationScreen extends StatelessWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ModerationState>(
      onInit: (store) => store.dispatch(LoadModerationAction()),
      converter: (store) => store.state.moderationState,
      builder: (context, state) {
        return ManagementPage(
          title: 'Moderation & Groups',
          subtitle:
              'Review reported posts, comments, and messages with clear group context and moderation state.',
          status: state.status,
          items: state.items,
          searchHint: 'Search reported content',
          headerActions: const [
            PremiumButton(
              label: 'Assign moderator',
              icon: Icons.admin_panel_settings_rounded,
            ),
          ],
          columns: [
            AdminTableColumn<ModerationItem>(
              label: 'Type',
              cellBuilder: (item) => Text(item.type),
            ),
            AdminTableColumn<ModerationItem>(
              label: 'Author',
              cellBuilder: (item) => Text(item.author),
            ),
            AdminTableColumn<ModerationItem>(
              label: 'Group',
              cellBuilder: (item) => Text(item.groupName),
            ),
            AdminTableColumn<ModerationItem>(
              label: 'Preview',
              cellBuilder: (item) => Text(item.preview),
            ),
            AdminTableColumn<ModerationItem>(
              label: 'State',
              cellBuilder: (item) => StatusBadge(item.status),
            ),
          ],
          onRetry: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(LoadModerationAction()),
        );
      },
    );
  }
}
