import 'package:eduhub/fake_data/data.dart';
import 'package:flutter/material.dart';
import '../widgets/student_card.dart';
import '../widgets/student_search_bar.dart';
import '../widgets/student_filter_bar.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String searchQuery = "";
  String? selectedDepartment;
  int? selectedYear;

  @override
  Widget build(BuildContext context) {
    final filtered = students.where((student) {
      final matchesSearch = student["name"].toString().toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      final matchesDepartment =
          selectedDepartment == null ||
          student["department"] == selectedDepartment;

      final matchesYear =
          selectedYear == null || student["year"] == selectedYear;

      return matchesSearch && matchesDepartment && matchesYear;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(223, 91, 92, 103),
        title: Center(
          child: Text(
            "admin",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF0F172A),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            StudentSearchBar(onChanged: (v) => setState(() => searchQuery = v)),

            const SizedBox(height: 12),

            StudentFilterBar(
              selectedDepartment: selectedDepartment,
              selectedYear: selectedYear,
              onDepartmentChange: (d) => setState(() => selectedDepartment = d),
              onYearChange: (y) => setState(() => selectedYear = y),
            ),

            const SizedBox(height: 22),

            Expanded(
              child: GridView.builder(
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.9,
                ),
                itemBuilder: (_, i) {
                  return StudentCard(student: filtered[i]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
