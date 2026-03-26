import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../shared/models/academic_models.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/management_page.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/sections_state.dart';

class SectionsScreen extends StatelessWidget {
  const SectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SectionsState>(
      onInit: (store) => store.dispatch(LoadSectionsAction()),
      converter: (store) => store.state.sectionsState,
      builder: (context, state) {
        return ManagementPage(
          title: 'Sections',
          subtitle:
              'Group sections by semester and year while keeping staff and offering alignment visible.',
          status: state.status,
          items: state.items,
          searchHint: 'Search sections',
          headerActions: const [
            PremiumButton(
              label: 'Create section',
              icon: Icons.dashboard_customize_rounded,
            ),
          ],
          columns: [
            AdminTableColumn<SectionModel>(
              label: 'Section',
              cellBuilder: (item) => Text(item.name),
            ),
            AdminTableColumn<SectionModel>(
              label: 'Department',
              cellBuilder: (item) => Text(item.department),
            ),
            AdminTableColumn<SectionModel>(
              label: 'Year',
              cellBuilder: (item) => Text(item.year),
            ),
            AdminTableColumn<SectionModel>(
              label: 'Semester',
              cellBuilder: (item) => Text(item.semester),
            ),
            AdminTableColumn<SectionModel>(
              label: 'Status',
              cellBuilder: (item) => StatusBadge(item.status),
            ),
          ],
          onRetry: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(LoadSectionsAction()),
        );
      },
    );
  }
}
