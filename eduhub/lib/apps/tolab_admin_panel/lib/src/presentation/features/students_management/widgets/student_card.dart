// ignore_for_file: deprecated_member_use

import 'package:eduhub/apps/tolab_admin_panel/lib/src/presentation/features/students_management/pages/student_details_page.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/app_state.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/students/students_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class StudentCard extends StatelessWidget {
  final Map<String, dynamic>? student;
  final OnInvokeCallback? onTap;

  const StudentCard({super.key, this.student, this.onTap});

  @override
  Widget build(BuildContext context) {
    final gpa = student?["gpa_current"];
    final statusColor = gpa >= 3.5
        ? Colors.green
        : gpa >= 3
        ? Colors.orange
        : Colors.red;

    return InkWell(
      onTap: () {
        StoreProvider.of<AppState>(context).dispatch(LoadStudentsAction());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDetailsPage(student: student!),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student?["name"],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${student?["department"]} • Year ${student?["year"]}",
              style: const TextStyle(color: Colors.white70),
            ),
            const Spacer(),
            Row(
              children: [
                Chip(
                  label: Text("GPA $gpa"),
                  backgroundColor: statusColor.withOpacity(.2),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
