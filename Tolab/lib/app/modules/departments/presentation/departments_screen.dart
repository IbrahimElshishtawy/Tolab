import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../shared/models/academic_models.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/management_page.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/departments_state.dart';

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DepartmentsState>(
      onInit: (store) => store.dispatch(LoadDepartmentsAction()),
      converter: (store) => store.state.departmentsState,
      builder: (context, state) {
        return ManagementPage(
          title: 'Departments',
          subtitle:
              'Control department metadata, leadership, and activation states.',
          status: state.status,
          items: state.items,
          searchHint: 'Search departments',
          headerActions: const [
            PremiumButton(
              label: 'New department',
              icon: Icons.apartment_rounded,
            ),
          ],
          columns: [
            AdminTableColumn<DepartmentModel>(
              label: 'Department',
              cellBuilder: (item) => Text(item.name),
            ),
            AdminTableColumn<DepartmentModel>(
              label: 'Code',
              cellBuilder: (item) => Text(item.code),
            ),
            AdminTableColumn<DepartmentModel>(
              label: 'Head',
              cellBuilder: (item) => Text(item.head),
            ),
            AdminTableColumn<DepartmentModel>(
              label: 'Students',
              cellBuilder: (item) => Text(item.studentsCount.toString()),
            ),
            AdminTableColumn<DepartmentModel>(
              label: 'Status',
              cellBuilder: (item) => StatusBadge(item.status),
            ),
          ],
          onRetry: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(LoadDepartmentsAction()),
        );
      },
    );
  }
}
