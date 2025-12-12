// ignore_for_file: deprecated_member_use

import 'package:eduhub/fake_data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../state/app_state.dart';
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
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.permissions.canViewStudents,
      builder: (context, canViewStudents) {
        // -----------------------------------
        // ACCESS DENIED
        // -----------------------------------
        if (!canViewStudents) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
              child: Text(
                "Access Denied",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        // -----------------------------------
        // FILTER LOGIC
        // -----------------------------------
        final filtered = students.where((student) {
          final matchesSearch =
              searchQuery.isEmpty ||
              student["name"].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              );

          final matchesDepartment =
              selectedDepartment == null ||
              student["department"] == selectedDepartment;

          final matchesYear =
              selectedYear == null || student["year"] == selectedYear;

          return matchesSearch && matchesDepartment && matchesYear;
        }).toList();

        // -----------------------------------
        // MAIN UI
        // -----------------------------------
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),

          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Students Management",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // -----------------------------
                // SEARCH
                // -----------------------------
                StudentSearchBar(
                  onChanged: (v) => setState(() => searchQuery = v),
                ),

                const SizedBox(height: 14),

                // -----------------------------
                // FILTERS
                // -----------------------------
                StudentFilterBar(
                  selectedDepartment: selectedDepartment,
                  selectedYear: selectedYear,
                  onDepartmentChange: (d) =>
                      setState(() => selectedDepartment = d),
                  onYearChange: (y) => setState(() => selectedYear = y),
                ),

                const SizedBox(height: 24),

                // -----------------------------
                // STUDENTS GRID
                // -----------------------------
                Expanded(
                  child: GridView.builder(
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
      },
    );
  }
}
