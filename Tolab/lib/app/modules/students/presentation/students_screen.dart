import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../shared/models/student.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/management_page.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/students_state.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, StudentsState>(
      onInit: (store) => store.dispatch(LoadStudentsAction()),
      converter: (store) => store.state.studentsState,
      builder: (context, state) {
        return ManagementPage(
          title: 'Students',
          subtitle:
              'Search, review, and inspect academic placement, activity, and enrollment status.',
          status: state.status,
          items: state.items,
          searchHint: 'Search students',
          headerActions: const [
            PremiumButton(
              label: 'Add student',
              icon: Icons.person_add_alt_rounded,
            ),
          ],
          columns: [
            AdminTableColumn<Student>(
              label: 'Student',
              cellBuilder: (item) => Text(item.name),
            ),
            AdminTableColumn<Student>(
              label: 'Email',
              cellBuilder: (item) => Text(item.email),
            ),
            AdminTableColumn<Student>(
              label: 'Academic',
              cellBuilder: (item) => Text('${item.department} • ${item.level}'),
            ),
            AdminTableColumn<Student>(
              label: 'Performance',
              cellBuilder: (item) => Text('GPA ${item.gpa.toStringAsFixed(2)}'),
            ),
            AdminTableColumn<Student>(
              label: 'Status',
              cellBuilder: (item) => StatusBadge(item.status),
            ),
          ],
          onRetry: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(LoadStudentsAction()),
        );
      },
    );
  }
}
