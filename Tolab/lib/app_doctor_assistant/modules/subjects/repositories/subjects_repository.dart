import '../../../core/models/academic_models.dart';
import '../../../core/network/api_client.dart';

class SubjectsRepository {
  SubjectsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<SubjectModel>> fetchSubjects() async {
    final response = await _apiClient.get<List<SubjectModel>>(
      '/staff-portal/subjects',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SubjectModel.fromJson)
          .toList(),
    );

    return response.data ?? const <SubjectModel>[];
  }

  Future<SubjectModel> fetchSubjectDetail(int subjectId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff-portal/subjects/$subjectId',
      parser: (value) => Map<String, dynamic>.from(value as Map),
    );

    return SubjectModel.fromJson(response.data ?? const {});
  }
}
