import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/data/admin_data_table.dart';
import '../../../data/models/admin_models.dart';
import '../../shared/widgets/management_page.dart';
import '../controllers/doctors_controller.dart';

class DoctorsView extends GetView<DoctorsController> {
  const DoctorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementPage(
      title: 'Doctors',
      subtitle:
          'Faculty directory, office assignments, and workload visibility.',
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
