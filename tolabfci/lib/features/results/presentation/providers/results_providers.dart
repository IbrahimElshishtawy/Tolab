import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_results_repository.dart';

final resultsProvider = FutureProvider((ref) {
  return ref.watch(resultsRepositoryProvider).fetchResults();
});
