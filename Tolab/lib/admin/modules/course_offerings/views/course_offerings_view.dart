import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/data/admin_data_table.dart';
import '../../../data/models/admin_models.dart';
import '../../shared/widgets/management_page.dart';
import '../controllers/course_offerings_controller.dart';

class CourseOfferingsView extends GetView<CourseOfferingsController> {
  const CourseOfferingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementPage(
      title: 'Course Offerings',
      subtitle:
          'Publish semester offerings, capacity, and live enrollment coverage.',
      controller: controller,
      columns: [
        AdminTableColumn<CourseOfferingModel>(
          label: 'Subject',
          cellBuilder: (item) => item.subjectName,
        ),
        AdminTableColumn<CourseOfferingModel>(
          label: 'Semester',
          cellBuilder: (item) => item.semester,
        ),
        AdminTableColumn<CourseOfferingModel>(
          label: 'Capacity',
          cellBuilder: (item) => '${item.enrolled}/${item.capacity}',
        ),
        AdminTableColumn<CourseOfferingModel>(
          label: 'Status',
          cellBuilder: (item) => item.status,
        ),
      ],
    );
  }
}
