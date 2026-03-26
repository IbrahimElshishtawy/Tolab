import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../shared/models/staff_member.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/management_page.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/staff_state.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, StaffState>(
      onInit: (store) => store.dispatch(LoadStaffAction()),
      converter: (store) => store.state.staffState,
      builder: (context, state) {
        return ManagementPage(
          title: 'Doctors & Assistants',
          subtitle:
              'Manage staffing assignments, subject ownership, department tags, and account states.',
          status: state.status,
          items: state.items,
          searchHint: 'Search staff',
          headerActions: const [
            PremiumButton(
              label: 'Invite staff',
              icon: Icons.person_add_alt_1_rounded,
            ),
          ],
          columns: [
            AdminTableColumn<StaffMember>(
              label: 'Name',
              cellBuilder: (item) => Text(item.name),
            ),
            AdminTableColumn<StaffMember>(
              label: 'Role',
              cellBuilder: (item) => Text(item.title),
            ),
            AdminTableColumn<StaffMember>(
              label: 'Department',
              cellBuilder: (item) => Text(item.department),
            ),
            AdminTableColumn<StaffMember>(
              label: 'Subjects',
              cellBuilder: (item) => Text('${item.subjects} assigned'),
            ),
            AdminTableColumn<StaffMember>(
              label: 'Status',
              cellBuilder: (item) => StatusBadge(item.status),
            ),
          ],
          onRetry: () =>
              StoreProvider.of<AppState>(context).dispatch(LoadStaffAction()),
        );
      },
    );
  }
}
