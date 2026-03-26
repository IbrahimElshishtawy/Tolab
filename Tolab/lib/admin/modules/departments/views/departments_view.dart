import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/data/admin_data_table.dart';
import '../../../data/models/admin_models.dart';
import '../../shared/widgets/management_page.dart';
import '../controllers/departments_controller.dart';

class DepartmentsView extends GetView<DepartmentsController> {
  const DepartmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementPage(
      title: 'Departments',
      subtitle: 'Manage department heads, scope, and academic structure.',
      controller: controller,
      columns: [
        AdminTableColumn<DepartmentModel>(
          label: 'Department',
          cellBuilder: (item) => item.name,
        ),
        AdminTableColumn<DepartmentModel>(
          label: 'Head',
          cellBuilder: (item) => item.head,
        ),
        AdminTableColumn<DepartmentModel>(
          label: 'Students',
          cellBuilder: (item) => item.studentsCount.toString(),
        ),
        AdminTableColumn<DepartmentModel>(
          label: 'Status',
          cellBuilder: (item) => item.status,
        ),
      ],
    );
  }
}
