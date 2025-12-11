import 'package:eduhub/fake_data/data.dart';

class ApiServiceDoctors {
  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return professors;
  }

  Future<Map<String, dynamic>> fetchDoctorById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return professors.firstWhere((d) => d["professor_id"] == id);
    } catch (e) {
      throw Exception("Doctor not found");
    }
  }

  Future<List<Map<String, dynamic>>> searchDoctors(String query) async {
    await Future.delayed(const Duration(milliseconds: 240));

    query = query.toLowerCase();

    return professors.where((doctor) {
      return doctor["name"].toLowerCase().contains(query) ||
          doctor["email"].toLowerCase().contains(query) ||
          doctor["professor_id"].toLowerCase().contains(query);
    }).toList();
  }

  Future<List<String>> fetchDepartments() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final set = <String>{};
    for (var d in professors) {
      set.add(d["department"]);
    }
    return set.toList();
  }
}
