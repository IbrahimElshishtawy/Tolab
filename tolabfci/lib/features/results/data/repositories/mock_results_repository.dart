import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/result_item.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../domain/repositories/results_repository.dart';

final resultsRepositoryProvider = Provider<ResultsRepository>((ref) {
  return MockResultsRepository(ref.watch(mockBackendServiceProvider));
});

class MockResultsRepository implements ResultsRepository {
  const MockResultsRepository(this._backendService);

  final MockBackendService _backendService;

  @override
  Future<List<SubjectResult>> fetchResults() => _backendService.fetchResults();
}
