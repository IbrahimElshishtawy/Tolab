import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../../../../../app_admin/shared/widgets/status_badge.dart';
import '../../models/results_models.dart';

class GradeTableWidget extends StatelessWidget {
  const GradeTableWidget({
    super.key,
    required this.students,
    required this.category,
    required this.controllers,
  });

  final List<GradeStudentRowModel> students;
  final GradeCategoryModel category;
  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Student')),
            DataColumn(label: Text('Code')),
            DataColumn(label: Text('Current')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Edit')),
            DataColumn(label: Text('Notes')),
          ],
          rows: students.map((student) {
            final entry = student.entries[category.key];
            final controller = controllers.putIfAbsent(
              student.studentCode,
              () => TextEditingController(
                text: entry?.score?.toStringAsFixed(1) ?? '',
              ),
            );
            return DataRow(
              cells: [
                DataCell(Text(student.studentName)),
                DataCell(Text(student.studentCode)),
                DataCell(Text(
                  entry?.score == null
                      ? '--'
                      : '${entry!.score!.toStringAsFixed(1)}/${entry.maxScore.toStringAsFixed(0)}',
                )),
                DataCell(StatusBadge(entry?.statusLabel ?? student.statusLabel)),
                DataCell(
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: '0',
                      ),
                    ),
                  ),
                ),
                DataCell(Text(student.notes ?? '--')),
              ],
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}
