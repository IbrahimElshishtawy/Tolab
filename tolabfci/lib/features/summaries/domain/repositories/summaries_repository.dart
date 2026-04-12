import '../../../../core/models/subject_models.dart';

abstract class SummariesRepository {
  Future<List<SummaryItem>> fetchSummaries(String subjectId);

  Future<void> addSummary({
    required String subjectId,
    required String title,
    String? videoUrl,
    String? attachmentName,
  });
}
