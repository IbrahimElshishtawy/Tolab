import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../shared/models/academic_models.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/management_page.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/subjects_state.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SubjectsState>(
      onInit: (store) => store.dispatch(LoadSubjectsAction()),
      converter: (store) => store.state.subjectsState,
      builder: (context, state) {
        return ManagementPage(
          title: 'Subjects',
          subtitle:
              'Manage subject metadata, credits, departmental ownership, and delivery status.',
          status: state.status,
          items: state.items,
          searchHint: 'Search subjects',
          headerActions: const [
            PremiumButton(
              label: 'Add subject',
              icon: Icons.auto_stories_rounded,
            ),
          ],
          columns: [
            AdminTableColumn<SubjectModel>(
              label: 'Code',
              cellBuilder: (item) => Text(item.code),
            ),
            AdminTableColumn<SubjectModel>(
              label: 'Subject',
              cellBuilder: (item) => Text(item.name),
            ),
            AdminTableColumn<SubjectModel>(
              label: 'Department',
              cellBuilder: (item) => Text(item.department),
            ),
            AdminTableColumn<SubjectModel>(
              label: 'Credits',
              cellBuilder: (item) => Text(item.credits.toString()),
            ),
            AdminTableColumn<SubjectModel>(
              label: 'Status',
              cellBuilder: (item) => StatusBadge(item.status),
            ),
          ],
          onRetry: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(LoadSubjectsAction()),
        );
      },
    );
  }
}
