import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/data/admin_data_table.dart';
import '../../../data/models/admin_models.dart';
import '../../shared/widgets/management_page.dart';
import '../controllers/enrollments_controller.dart';

class EnrollmentsView extends GetView<EnrollmentsController> {
  const EnrollmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementPage(
      title: 'Enrollments',
      subtitle:
          'Review registration flow, approvals, and subject allocation health.',
      controller: controller,
      columns: [
        AdminTableColumn<EnrollmentModel>(
          label: 'Student',
          cellBuilder: (item) => item.studentName,
        ),
        AdminTableColumn<EnrollmentModel>(
          label: 'Subject',
          cellBuilder: (item) => item.subjectName,
        ),
        AdminTableColumn<EnrollmentModel>(
          label: 'Batch',
          cellBuilder: (item) => item.batch,
        ),
        AdminTableColumn<EnrollmentModel>(
          label: 'Status',
          cellBuilder: (item) => item.status,
        ),
      ],
    );
  }
}
