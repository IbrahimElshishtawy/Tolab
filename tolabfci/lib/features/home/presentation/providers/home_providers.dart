import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_home_repository.dart';

final homeDashboardProvider = FutureProvider((ref) {
  return ref.watch(homeRepositoryProvider).fetchDashboard();
});
