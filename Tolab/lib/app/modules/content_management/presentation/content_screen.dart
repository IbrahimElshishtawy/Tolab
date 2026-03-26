import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../shared/models/content_models.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/management_page.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/content_state.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ContentState>(
      onInit: (store) => store.dispatch(LoadContentAction()),
      converter: (store) => store.state.contentState,
      builder: (context, state) {
        return ManagementPage(
          title: 'Content Management',
          subtitle:
              'Control lectures, quizzes, exams, summaries, and attached resources across offerings.',
          status: state.status,
          items: state.items,
          searchHint: 'Search content items',
          headerActions: const [
            PremiumButton(
              label: 'Create content',
              icon: Icons.edit_note_rounded,
            ),
          ],
          columns: [
            AdminTableColumn<ContentItem>(
              label: 'Course',
              cellBuilder: (item) => Text(item.courseTitle),
            ),
            AdminTableColumn<ContentItem>(
              label: 'Type',
              cellBuilder: (item) => Text(item.type),
            ),
            AdminTableColumn<ContentItem>(
              label: 'Title',
              cellBuilder: (item) => Text(item.title),
            ),
            AdminTableColumn<ContentItem>(
              label: 'Due / Files',
              cellBuilder: (item) => Text(
                '${item.dueDateLabel ?? 'No date'} • ${item.attachments} files',
              ),
            ),
            AdminTableColumn<ContentItem>(
              label: 'Status',
              cellBuilder: (item) => StatusBadge(item.status),
            ),
          ],
          onRetry: () =>
              StoreProvider.of<AppState>(context).dispatch(LoadContentAction()),
        );
      },
    );
  }
}
