import 'package:eduhub/fake_data/data.dart';

class ApiServiceAssistants {
  Future<List<Map<String, dynamic>>> fetchAssistants() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return assistants;
  }

  Future<Map<String, dynamic>> fetchAssistantById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return assistants.firstWhere((a) => a["assistant_id"] == id);
    } catch (e) {
      throw Exception("Assistant not found");
    }
  }

  Future<List<Map<String, dynamic>>> searchAssistants(String query) async {
    await Future.delayed(const Duration(milliseconds: 240));

    query = query.toLowerCase();

    return assistants.where((assistant) {
      return assistant["name"].toLowerCase().contains(query) ||
          assistant["email"].toLowerCase().contains(query) ||
          assistant["assistant_id"].toLowerCase().contains(query);
    }).toList();
  }

  Future<List<String>> fetchDepartments() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final set = <String>{};
    for (var a in assistants) {
      set.add(a["department"]);
    }
    return set.toList();
  }
}
