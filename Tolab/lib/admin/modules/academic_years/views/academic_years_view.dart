import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/data/admin_data_table.dart';
import '../../../data/models/admin_models.dart';
import '../../shared/widgets/management_page.dart';
import '../controllers/academic_years_controller.dart';

class AcademicYearsView extends GetView<AcademicYearsController> {
  const AcademicYearsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementPage(
      title: 'Academic Years',
      subtitle: 'Control year ranges, active cycles, and historical archives.',
      controller: controller,
      columns: [
        AdminTableColumn<AcademicYearModel>(
          label: 'Year',
          cellBuilder: (item) => item.name,
        ),
        AdminTableColumn<AcademicYearModel>(
          label: 'Range',
          cellBuilder: (item) => item.secondaryLabel,
        ),
        AdminTableColumn<AcademicYearModel>(
          label: 'Status',
          cellBuilder: (item) => item.status,
        ),
      ],
    );
  }
}
