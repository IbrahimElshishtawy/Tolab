import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/data/admin_data_table.dart';
import '../../../data/models/admin_models.dart';
import '../../shared/widgets/management_page.dart';
import '../controllers/subjects_controller.dart';

class SubjectsView extends GetView<SubjectsController> {
  const SubjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementPage(
      title: 'Subjects',
      subtitle:
          'Maintain subject catalog, codes, credits, and faculty ownership.',
      controller: controller,
      columns: [
        AdminTableColumn<SubjectModel>(
          label: 'Subject',
          cellBuilder: (item) => item.primaryLabel,
        ),
        AdminTableColumn<SubjectModel>(
          label: 'Department',
          cellBuilder: (item) => item.department,
        ),
        AdminTableColumn<SubjectModel>(
          label: 'Doctor',
          cellBuilder: (item) => item.doctorName,
        ),
        AdminTableColumn<SubjectModel>(
          label: 'Status',
          cellBuilder: (item) => item.status,
        ),
      ],
    );
  }
}
