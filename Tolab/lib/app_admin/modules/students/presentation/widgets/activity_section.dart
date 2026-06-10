import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/student_management_models.dart';
import '../../widgets/student_module_primitives.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({
    super.key,
    required this.activities,
    required this.studentsById,
  });

  final List<StudentActivityRecord> activities;
  final Map<String, StudentProfile> studentsById;

  @override
  Widget build(BuildContext context) {
    return StudentSectionCard(
      title: 'Activity tracking',
      subtitle:
          'Recent login, submission, forum, message, and approval events in a searchable table view.',
      child: SizedBox(
        height: 520,
        child: DataTable2(
          fixedTopRows: 1,
          minWidth: 980,
          columns: const [
            DataColumn2(label: Text('Student'), size: ColumnSize.L),
            DataColumn2(label: Text('Type')),
            DataColumn2(label: Text('Course')),
            DataColumn2(label: Text('Description'), size: ColumnSize.L),
            DataColumn2(label: Text('When')),
          ],
          rows: [
            for (final activity in activities)
              DataRow2(
                cells: [
                  DataCell(
                    Text(
                      studentsById[activity.studentId]?.fullName ?? 'Unknown',
                    ),
                  ),
                  DataCell(Text(activity.type.label)),
                  DataCell(Text(activity.courseTitle ?? 'General')),
                  DataCell(Text(activity.description)),
                  DataCell(
                    Text(
                      DateFormat('MMM d, HH:mm').format(activity.occurredAt),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
