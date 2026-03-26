import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/data/admin_data_table.dart';
import '../../../data/models/admin_models.dart';
import '../../shared/widgets/management_page.dart';
import '../controllers/assignments_controller.dart';

class AssignmentsView extends GetView<AssignmentsController> {
  const AssignmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementPage(
      title: 'Subject Assignments',
      subtitle:
          'Coordinate doctor and assistant ownership across active batches.',
      controller: controller,
      columns: [
        AdminTableColumn<SubjectAssignmentModel>(
          label: 'Subject',
          cellBuilder: (item) => item.subjectName,
        ),
        AdminTableColumn<SubjectAssignmentModel>(
          label: 'Doctor',
          cellBuilder: (item) => item.doctorName,
        ),
        AdminTableColumn<SubjectAssignmentModel>(
          label: 'Assistant',
          cellBuilder: (item) => item.assistantName,
        ),
        AdminTableColumn<SubjectAssignmentModel>(
          label: 'Status',
          cellBuilder: (item) => item.status,
        ),
      ],
    );
  }
}
