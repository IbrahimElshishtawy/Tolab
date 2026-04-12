import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/community_models.dart';
import '../../../../core/models/quiz_models.dart';
import '../../../../core/models/subject_models.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../domain/repositories/subjects_repository.dart';

final subjectsRepositoryProvider = Provider<SubjectsRepository>((ref) {
  return MockSubjectsRepository(ref.watch(mockBackendServiceProvider));
});

class MockSubjectsRepository implements SubjectsRepository {
  const MockSubjectsRepository(this._backendService);

  final MockBackendService _backendService;

  @override
  Future<void> addComment({
    required String subjectId,
    required String postId,
    required String content,
  }) {
    return _backendService.addComment(
      subjectId: subjectId,
      postId: postId,
      content: content,
    );
  }

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
  Future<List<ChatMessage>> fetchChatMessages(
    String subjectId, {
    int page = 0,
    int pageSize = 15,
  }) {
    return _backendService.fetchChatMessages(subjectId, page: page, pageSize: pageSize);
  }

  @override
  Future<List<CommunityPost>> fetchCommunityPosts(String subjectId) =>
      _backendService.fetchCommunityPosts(subjectId);

  @override
  Future<List<LectureItem>> fetchLectures(String subjectId) =>
      _backendService.fetchLectures(subjectId: subjectId);

  @override
  Future<List<QuizItem>> fetchQuizzes(String subjectId) =>
      _backendService.fetchQuizzes(subjectId: subjectId);

  @override
  Future<List<SectionItem>> fetchSections(String subjectId) =>
      _backendService.fetchSections(subjectId);

  @override
  Future<SubjectOverview> fetchSubjectById(String subjectId) =>
      _backendService.fetchSubjectById(subjectId);

  @override
  Future<List<SubjectOverview>> fetchSubjects() => _backendService.fetchSubjects();

  @override
  Future<List<SummaryItem>> fetchSummaries(String subjectId) =>
      _backendService.fetchSummaries(subjectId);

  @override
  Future<List<TaskItem>> fetchTasks(String subjectId) => _backendService.fetchTasks(subjectId);

  @override
  Future<void> reactToPost({required String subjectId, required String postId}) {
    return _backendService.reactToPost(subjectId: subjectId, postId: postId);
  }

  @override
  Future<void> sendChatMessage({
    required String subjectId,
    required String content,
  }) {
    return _backendService.sendChatMessage(subjectId: subjectId, content: content);
  }
}
