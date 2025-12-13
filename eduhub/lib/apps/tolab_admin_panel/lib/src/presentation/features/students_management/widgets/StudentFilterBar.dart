import 'package:flutter/material.dart';

class StudentFilterBar extends StatelessWidget {
  final String? programType;
  final String? department;
  final int? year;

  final ValueChanged<String?> onProgramChange;
  final ValueChanged<String?> onDepartmentChange;
  final ValueChanged<int?> onYearChange;

  const StudentFilterBar({
    super.key,
    required this.programType,
    required this.department,
    required this.year,
    required this.onProgramChange,
    required this.onDepartmentChange,
    required this.onYearChange,
  });

  @override
  Widget build(BuildContext context) {
    final departments = programType == "General"
        ? ["General"]
        : ["Computer Science", "AI", "IT", "IS"];

    final years = programType == "General" ? [1, 2] : [1, 2, 3, 4];

    return Row(
      children: [
        Expanded(
          child: _dropdown(
            label: "Program",
            value: programType,
            items: ["General", "Credit", "Summer"],
            onChanged: onProgramChange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _dropdown(
            label: "Department",
            value: department,
            items: departments,
            onChanged: onDepartmentChange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _dropdown(
            label: "Year",
            value: year,
            items: years.map((e) => e.toString()).toList(),
            onChanged: (v) => onYearChange(int.tryParse(v!)),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required dynamic value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}
