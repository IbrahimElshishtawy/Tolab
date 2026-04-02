import '../../../core/models/content_models.dart';
import '../../../core/network/api_client.dart';

class SectionContentRepository {
  SectionContentRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<SectionContentModel>> fetchSectionContent() async {
    final response = await _apiClient.get<List<SectionContentModel>>(
      '/staff-portal/section-content',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SectionContentModel.fromJson)
          .toList(),
    );

    return response.data ?? const <SectionContentModel>[];
  }

  Future<void> saveSectionContent(Map<String, dynamic> payload) async {
    await _apiClient.post<Object?>(
      '/staff-portal/section-content',
      data: payload,
      parser: (_) => null,
    );
  }
}
