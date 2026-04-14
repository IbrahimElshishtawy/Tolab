import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/subject_models.dart';
import '../../data/repositories/mock_summaries_repository.dart';

final summariesControllerProvider =
    AsyncNotifierProvider.family<SummariesController, List<SummaryItem>, String>(
  SummariesController.new,
);

class SummariesController extends AsyncNotifier<List<SummaryItem>> {
  SummariesController(this._subjectId);
  final String _subjectId;

  @override
  Future<List<SummaryItem>> build() async {
    return ref.watch(summariesRepositoryProvider).fetchSummaries(_subjectId);
  }

  Future<void> addSummary({
    required String title,
    String? videoUrl,
    String? attachmentName,
  }) async {
    await ref.read(summariesRepositoryProvider).addSummary(
          subjectId: _subjectId,
          title: title,
          videoUrl: videoUrl,
          attachmentName: attachmentName,
        );
    state = AsyncData(
      await ref.read(summariesRepositoryProvider).fetchSummaries(_subjectId),
    );
  }
}
