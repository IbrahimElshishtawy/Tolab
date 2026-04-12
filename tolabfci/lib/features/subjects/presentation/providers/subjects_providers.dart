import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_subjects_repository.dart';

final subjectsProvider = FutureProvider((ref) {
  return ref.watch(subjectsRepositoryProvider).fetchSubjects();
});

final subjectByIdProvider = FutureProvider.family((ref, String subjectId) {
  return ref.watch(subjectsRepositoryProvider).fetchSubjectById(subjectId);
});

final lecturesProvider = FutureProvider.family((ref, String subjectId) {
  return ref.watch(subjectsRepositoryProvider).fetchLectures(subjectId);
});

final sectionsProvider = FutureProvider.family((ref, String subjectId) {
  return ref.watch(subjectsRepositoryProvider).fetchSections(subjectId);
});

final tasksProvider = FutureProvider.family((ref, String subjectId) {
  return ref.watch(subjectsRepositoryProvider).fetchTasks(subjectId);
});

final summariesProvider = FutureProvider.family((ref, String subjectId) {
  return ref.watch(subjectsRepositoryProvider).fetchSummaries(subjectId);
});
