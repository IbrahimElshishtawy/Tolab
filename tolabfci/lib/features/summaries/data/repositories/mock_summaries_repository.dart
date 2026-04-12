import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../domain/repositories/summaries_repository.dart';

final summariesRepositoryProvider = Provider<SummariesRepository>((ref) {
  return MockSummariesRepository(ref.watch(mockBackendServiceProvider));
});

class MockSummariesRepository implements SummariesRepository {
  const MockSummariesRepository(this._backendService);

  final MockBackendService _backendService;

  @override
  Future<void> addSummary({
    required String subjectId,
    required String title,
    String? videoUrl,
    String? attachmentName,
  }) {
    return _backendService.addSummary(
      subjectId: subjectId,
      title: title,
      videoUrl: videoUrl,
      attachmentName: attachmentName,
    );
  }

  @override
  Future<List<SummaryItem>> fetchSummaries(String subjectId) =>
      _backendService.fetchSummaries(subjectId);
}
