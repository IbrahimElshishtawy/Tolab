import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/data/admin_data_table.dart';
import '../../../data/models/admin_models.dart';
import '../../shared/widgets/management_page.dart';
import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementPage(
      title: 'Schedule',
      subtitle: 'Coordinate timetable slots, locations, and ownership changes.',
      controller: controller,
      columns: [
        AdminTableColumn<ScheduleItemModel>(
          label: 'Title',
          cellBuilder: (item) => item.title,
        ),
        AdminTableColumn<ScheduleItemModel>(
          label: 'Day',
          cellBuilder: (item) => item.day,
        ),
        AdminTableColumn<ScheduleItemModel>(
          label: 'Time',
          cellBuilder: (item) => item.time,
        ),
        AdminTableColumn<ScheduleItemModel>(
          label: 'Owner',
          cellBuilder: (item) => item.owner,
        ),
      ],
    );
  }
}
