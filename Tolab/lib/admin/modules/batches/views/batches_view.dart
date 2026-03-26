import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/data/admin_data_table.dart';
import '../../../data/models/admin_models.dart';
import '../../shared/widgets/management_page.dart';
import '../controllers/batches_controller.dart';

class BatchesView extends GetView<BatchesController> {
  const BatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementPage(
      title: 'Batches',
      subtitle:
          'Organize student groups, yearly cohorts, and department intake.',
      controller: controller,
      columns: [
        AdminTableColumn<BatchModel>(
          label: 'Batch',
          cellBuilder: (item) => item.name,
        ),
        AdminTableColumn<BatchModel>(
          label: 'Department',
          cellBuilder: (item) => item.department,
        ),
        AdminTableColumn<BatchModel>(
          label: 'Students',
          cellBuilder: (item) => item.studentsCount.toString(),
        ),
        AdminTableColumn<BatchModel>(
          label: 'Status',
          cellBuilder: (item) => item.status,
        ),
      ],
    );
  }
}
