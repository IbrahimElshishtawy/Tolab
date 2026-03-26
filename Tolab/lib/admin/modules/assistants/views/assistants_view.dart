import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/data/admin_data_table.dart';
import '../../../data/models/admin_models.dart';
import '../../shared/widgets/management_page.dart';
import '../controllers/assistants_controller.dart';

class AssistantsView extends GetView<AssistantsController> {
  const AssistantsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementPage(
      title: 'Assistants',
      subtitle:
          'Track TA availability, labs, and supporting faculty allocations.',
      controller: controller,
      columns: [
        AdminTableColumn<StaffModel>(
          label: 'Name',
          cellBuilder: (item) => item.name,
        ),
        AdminTableColumn<StaffModel>(
          label: 'Department',
          cellBuilder: (item) => item.department,
        ),
        AdminTableColumn<StaffModel>(
          label: 'Role',
          cellBuilder: (item) => item.role,
        ),
        AdminTableColumn<StaffModel>(
          label: 'Office',
          cellBuilder: (item) => item.office,
        ),
        AdminTableColumn<StaffModel>(
          label: 'Status',
          cellBuilder: (item) => item.status,
        ),
      ],
    );
  }
}
