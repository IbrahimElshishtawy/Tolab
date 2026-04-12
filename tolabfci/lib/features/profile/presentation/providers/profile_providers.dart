import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_profile_repository.dart';

final profileProvider = FutureProvider((ref) {
  return ref.watch(profileRepositoryProvider).fetchProfile();
});
