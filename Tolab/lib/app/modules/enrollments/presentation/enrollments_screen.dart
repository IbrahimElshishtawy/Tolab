import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../shared/models/academic_models.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/management_page.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/enrollments_state.dart';

class EnrollmentsScreen extends StatelessWidget {
  const EnrollmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, EnrollmentsState>(
      onInit: (store) => store.dispatch(LoadEnrollmentsAction()),
      converter: (store) => store.state.enrollmentsState,
      builder: (context, state) {
        return ManagementPage(
          title: 'Enrollments',
          subtitle:
              'Handle manual and bulk enrollments with clear subject, level, and departmental context.',
          status: state.status,
          items: state.items,
          searchHint: 'Search enrollments',
          headerActions: const [
            PremiumButton(
              label: 'Bulk enroll',
              icon: Icons.upload_file_rounded,
            ),
          ],
          columns: [
            AdminTableColumn<EnrollmentRecord>(
              label: 'Student',
              cellBuilder: (item) => Text(item.studentName),
            ),
            AdminTableColumn<EnrollmentRecord>(
              label: 'Subject',
              cellBuilder: (item) => Text(item.subjectName),
            ),
            AdminTableColumn<EnrollmentRecord>(
              label: 'Department',
              cellBuilder: (item) => Text(item.department),
            ),
            AdminTableColumn<EnrollmentRecord>(
              label: 'Level',
              cellBuilder: (item) => Text(item.level),
            ),
            AdminTableColumn<EnrollmentRecord>(
              label: 'Status',
              cellBuilder: (item) => StatusBadge(item.status),
            ),
          ],
          onRetry: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(LoadEnrollmentsAction()),
        );
      },
    );
  }
}
