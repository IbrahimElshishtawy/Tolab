// TODO Implement this library.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class StudentFilterBar extends StatelessWidget {
  final String? selectedDepartment;
  final int? selectedYear;

  final ValueChanged<String?> onDepartmentChange;
  final ValueChanged<int?> onYearChange;

  const StudentFilterBar({
    super.key,
    required this.selectedDepartment,
    required this.selectedYear,
    required this.onDepartmentChange,
    required this.onYearChange,
  });

  @override
  Widget build(BuildContext context) {
    final departments = ["Computer Science", "AI", "Information Systems", "IT"];
    final years = [1, 2, 3, 4];

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: selectedDepartment,
            items: departments.map((d) {
              return DropdownMenuItem(
                value: d,
                child: Text(d, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: onDepartmentChange,
            dropdownColor: const Color(0xFF1E293B),
            decoration: _decor("Department"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: selectedYear,
            items: years.map((y) {
              return DropdownMenuItem(
                value: y,
                child: Text(
                  "Year $y",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: onYearChange,
            dropdownColor: const Color(0xFF1E293B),
            decoration: _decor("Year"),
          ),
        ),
      ],
    );
  }

  InputDecoration _decor(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
