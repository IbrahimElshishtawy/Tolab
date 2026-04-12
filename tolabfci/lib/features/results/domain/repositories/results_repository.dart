import '../../../../core/models/result_item.dart';

abstract class ResultsRepository {
  Future<List<SubjectResult>> fetchResults();
}
