import 'package:eduhub/apps/tolab_admin_panel/lib/src/presentation/features/students_management/models/StudentsVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../state/app_state.dart';

import '../widgets/student_card.dart';
import '../widgets/student_filter_bar.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, StudentsVM>(
      converter: StudentsVM.fromStore,
      builder: (context, vm) {
        // 🔐 Permissions Guard
        if (!vm.canViewStudents) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
              child: Text(
                "Access Denied",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),

          // 🧠 AppBar احترافي
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            leading: const BackButton(color: Colors.white),
            title: const Text("Students Management"),
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {}, // Export later
              ),
              if (vm.canEditStudents)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {},
                ),
            ],
          ),

          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 🧩 Filters Panel
                StudentFilterBar(
                  selectedDepartment: vm.department,
                  selectedYear: vm.year,
                  onDepartmentChange: vm.onDepartmentChange,
                  onYearChange: vm.onYearChange,
                ),

                const SizedBox(height: 24),

                // 🧩 Students Grid
                Expanded(
                  child: GridView.builder(
                    itemCount: vm.students.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 1.9,
                        ),
                    itemBuilder: (_, i) {
                      return StudentCard(student: vm.students[i]);
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
