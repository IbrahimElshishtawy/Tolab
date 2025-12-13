import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/app_state.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/students/students_state.dart';
import 'package:eduhub/fake_data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../widgets/student_card.dart';
import '../widgets/student_filter_bar.dart';
import 'dart:convert'; // لتحويل البيانات لملف JSON
import 'dart:io'; // لحفظ الملف

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String searchQuery = "";
  String? selectedDepartment;
  int? selectedYear;
  String? selectedName; // متغير للبحث عن اسم الطالب
  Map<String, dynamic>? selectedStudent; // الطالب المختار لعرض التفاصيل

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, StudentsState>(
      converter: (store) => store.state.students,
      builder: (context, studentsState) {
        final filtered = student.where((student) {
          final matchesSearch = student["name"]
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

          final matchesDepartment =
              selectedDepartment == null ||
              student["department"].toString().toLowerCase().contains(
                selectedDepartment!.toLowerCase(),
              );

          final matchesYear =
              selectedYear == null || student["year"] == selectedYear;

          final matchesName =
              selectedName == null ||
              student["name"].toString().toLowerCase().contains(
                selectedName!.toLowerCase(),
              );

          return matchesSearch &&
              matchesDepartment &&
              matchesYear &&
              matchesName;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF374151),
            title: const Center(
              child: Text(
                "إدارة الطلاب",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          backgroundColor: const Color(0xFF1F2937),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // شريط الفلاتر
                StudentFilterBar(
                  selectedDepartment: selectedDepartment,
                  selectedYear: selectedYear,
                  selectedName: selectedName,
                  onDepartmentChange: (d) =>
                      setState(() => selectedDepartment = d),
                  onYearChange: (y) => setState(() => selectedYear = y),
                  onNameChange: (n) => setState(() => selectedName = n),
                ),
                const SizedBox(height: 20),

                // عرض الطلاب كشرائح تحت بعض
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedStudent = filtered[i];
                          });
                        },
                        child: StudentCard(student: filtered[i]),
                      );
                    },
                  ),
                ),

                // إذا تم اختيار طالب، عرض تفاصيله في مربع كبير
                if (selectedStudent != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تفاصيل الطالب: ${selectedStudent!['name']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('القسم: ${selectedStudent!['department']}'),
                            Text('السنة الدراسية: ${selectedStudent!['year']}'),
                            Text('المعدل: ${selectedStudent!['gpa_current']}'),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                _saveStudentDetailsAsFile(selectedStudent!);
                              },
                              child: Text('حفظ التفاصيل كملف'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دالة لحفظ التفاصيل كملف JSON
  void _saveStudentDetailsAsFile(Map<String, dynamic> student) async {
    final directory = await Directory.systemTemp.createTemp();
    final file = File('${directory.path}/student_${student["name"]}.json');
    await file.writeAsString(jsonEncode(student));
    // إظهار رسالة أن الملف تم حفظه
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ التفاصيل كملف في: ${file.path}')),
    );
  }
}
