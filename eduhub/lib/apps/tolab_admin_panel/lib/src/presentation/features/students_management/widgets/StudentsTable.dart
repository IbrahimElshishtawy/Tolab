import 'package:flutter/material.dart';

class StudentsTable extends StatelessWidget {
  final List<Map<String, dynamic>> students;

  const StudentsTable({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text("Name")),
        DataColumn(label: Text("Department")),
        DataColumn(label: Text("Year")),
        DataColumn(label: Text("GPA")),
      ],
      rows: students.map((s) {
        return DataRow(
          cells: [
            DataCell(Text(s["name"])),
            DataCell(Text(s["department"])),
            DataCell(Text("Year ${s["year"]}")),
            DataCell(Text(s["gpa_current"].toString())),
          ],
        );
      }).toList(),
    );
  }
}
