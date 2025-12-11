import 'package:eduhub/fake_data/data.dart';

class ApiServiceStudents {
  Future<List<Map<String, dynamic>>> fetchStudents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return students;
  }

  Future<Map<String, dynamic>> fetchStudentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return students.firstWhere((s) => s["student_id"] == id);
    } catch (e) {
      throw Exception("Student not found");
    }
  }

  Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    await Future.delayed(const Duration(milliseconds: 240));

    query = query.toLowerCase();

    return students.where((student) {
      return student["name"].toString().toLowerCase().contains(query) ||
          student["email"].toLowerCase().contains(query) ||
          student["student_id"].toLowerCase().contains(query);
    }).toList();
  }

  Future<List<String>> fetchDepartments() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final set = <String>{};
    for (var s in students) {
      set.add(s["department"]);
    }
    return set.toList();
  }
}
