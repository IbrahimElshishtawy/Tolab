import 'package:flutter/material.dart';

class StudentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailsPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final attendance = student["attendance"];
    final grades = student["subjects_grades"] as Map;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(student["name"]),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            _info("Student ID", student["student_id"]),
            _info("Email", student["email"]),
            _info("Department", student["department"]),
            _info("Year", student["year"].toString()),
            _info("Status", student["status"]),
            const SizedBox(height: 20),

            _section("Grades"),
            ...grades.entries.map((e) => _info(e.key, e.value.toString())),

            const SizedBox(height: 20),

            _section("Attendance"),
            _info("Total Classes", attendance["total_classes"].toString()),
            _info("Attended", attendance["classes_attended"].toString()),
            _info("Percentage", "${attendance["attendance_percentage"]}%"),

            const SizedBox(height: 20),

            _section("Comments"),
            ...student["comments"].map<Widget>((c) {
              return _info(c["date"], c["content"]);
            }),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(title, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
