import '../../../../core/models/community_models.dart';
import '../../../../core/models/quiz_models.dart';
import '../../../../core/models/subject_models.dart';

abstract class SubjectsRepository {
  Future<List<SubjectOverview>> fetchSubjects();

  Future<SubjectOverview> fetchSubjectById(String subjectId);

  Future<List<LectureItem>> fetchLectures(String subjectId);

  Future<List<SectionItem>> fetchSections(String subjectId);

  Future<List<TaskItem>> fetchTasks(String subjectId);

  Future<List<SubjectFileItem>> fetchSubjectFiles(String subjectId);

  Future<List<SummaryItem>> fetchSummaries(String subjectId);

  Future<void> addSummary({
    required String subjectId,
    required String title,
    String? videoUrl,
    String? attachmentName,
  });

  Future<List<QuizItem>> fetchQuizzes(String subjectId);

  Future<TaskItem> uploadAssignment({
    required String subjectId,
    required String taskId,
    required String fileName,
  });

  Future<List<CommunityPost>> fetchCommunityPosts(String subjectId);

  Future<void> addComment({
    required String subjectId,
    required String postId,
    required String content,
  });

  Future<void> reactToPost({
    required String subjectId,
    required String postId,
  });

  Future<List<ChatMessage>> fetchChatMessages(
    String subjectId, {
    int page = 0,
    int pageSize = 15,
  });

  Future<void> sendChatMessage({
    required String subjectId,
    required String content,
  });
}
