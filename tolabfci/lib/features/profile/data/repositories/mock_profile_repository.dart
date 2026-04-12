import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/student_profile.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository(ref.watch(mockBackendServiceProvider));
});

class MockProfileRepository implements ProfileRepository {
  const MockProfileRepository(this._backendService);

  final MockBackendService _backendService;

  @override
  Future<StudentProfile> fetchProfile() => _backendService.fetchProfile();
}
