import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../core/widgets/data/admin_data_table.dart';
import '../../../data/models/admin_models.dart';
import '../../../routes/app_routes.dart';
import '../../shared/widgets/management_page.dart';
import '../controllers/students_controller.dart';

class StudentsView extends GetView<StudentsController> {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementPage(
      title: 'Students',
      subtitle:
          'Manage student records, academic assignments, and enrollment status.',
      controller: controller,
      onCreate: () => Get.toNamed(AppRoutes.studentForm),
      onTap: (item) =>
          Get.toNamed(AppRoutes.studentDetails, arguments: item.id),
      actionsBuilder: (item) => [
        IconButton(
          onPressed: () =>
              Get.toNamed(AppRoutes.studentForm, arguments: item.id),
          icon: const Icon(Icons.edit_rounded, size: 18),
        ),
        IconButton(
          onPressed: () async {
            final confirmed = await showConfirmDialog(
              title: 'Delete student',
              message:
                  'This will remove ${item.name} from the local admin list.',
              confirmLabel: 'Delete',
            );
            if (confirmed) {
              await controller.delete(item.id);
            }
          },
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
        ),
      ],
      columns: [
        AdminTableColumn<StudentModel>(
          label: 'Name',
          cellBuilder: (item) => item.name,
        ),
        AdminTableColumn<StudentModel>(
          label: 'Department',
          cellBuilder: (item) => item.department,
        ),
        AdminTableColumn<StudentModel>(
          label: 'Year',
          cellBuilder: (item) => item.academicYear,
        ),
        AdminTableColumn<StudentModel>(
          label: 'Batch',
          cellBuilder: (item) => item.batch,
        ),
        AdminTableColumn<StudentModel>(
          label: 'Status',
          cellBuilder: (item) => item.status,
        ),
      ],
    );
  }
}
