import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/home_dashboard.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../domain/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return MockHomeRepository(ref.watch(mockBackendServiceProvider));
});

class MockHomeRepository implements HomeRepository {
  const MockHomeRepository(this._backendService);

  final MockBackendService _backendService;

  @override
  Future<HomeDashboardData> fetchDashboard() => _backendService.fetchHomeDashboard();
}
