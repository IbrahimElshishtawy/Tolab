import 'package:flutter/material.dart';

class StudentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailsPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطالب - ${student["name"]}'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // يمكنك إضافة وظيفة التعديل هنا
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFF0F172A),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("البيانات الأساسية"),
              _buildDetailRow("الاسم", student["name"]),
              _buildDetailRow("البريد الإلكتروني", student["email"]),
              _buildDetailRow("السنة الدراسية", "السنة ${student["year"]}"),
              _buildDetailRow("القسم", student["department"]),
              const SizedBox(height: 20),

              _buildSectionTitle("الدرجات"),
              ...student["subjects_grades"].entries.map((entry) {
                return _buildGradeRow(entry.key, entry.value);
              }).toList(),
              const SizedBox(height: 20),

              _buildSectionTitle("الحضور"),
              _buildDetailRow(
                "الحضور الإجمالي",
                "${student["attendance"]["classes_attended"]} / ${student["attendance"]["total_classes"]}",
              ),
              _buildDetailRow(
                "نسبة الحضور",
                "${student["attendance"]["attendance_percentage"]}%",
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("التعليقات"),
              for (var comment in student["comments"])
                _buildCommentRow(comment["date"], comment["content"]),
              const SizedBox(height: 20),

              _buildSectionTitle("السجل الأكاديمي"),
              for (var record in student["academic_history"])
                _buildAcademicRecordRow(record["year"], record["gpa"]),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Helper method to build rows of details
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build grade rows
  Widget _buildGradeRow(String subject, double grade) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(subject, style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              grade.toString(),
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build comment rows
  Widget _buildCommentRow(String date, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "[$date]",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              content,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build academic record rows
  Widget _buildAcademicRecordRow(int year, double gpa) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "السنة $year",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              gpa.toString(),
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
