import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/timetable_item.dart';
import '../../data/repositories/mock_timetable_repository.dart';

final timetableItemsProvider = FutureProvider<List<TimetableItem>>((ref) {
  return ref.watch(timetableRepositoryProvider).getStudentTimetable();
});
