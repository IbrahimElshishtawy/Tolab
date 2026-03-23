import '../../core/constants/api_constants.dart';
import '../dto/pagination_query_dto.dart';
import '../models/course_content_model.dart';
import '../models/course_model.dart';
import '../models/grade_item_model.dart';
import '../models/paginated_response.dart';
import 'base_remote_data_source.dart';

class CoursesRemoteDataSource {
  CoursesRemoteDataSource(this._remote);

  final BaseRemoteDataSource _remote;

  Future<PaginatedResponse<CourseModel>> list(PaginationQueryDto query) async {
    final envelope = await _remote.get<PaginatedResponse<CourseModel>>(
      ApiConstants.courses,
      queryParameters: query.toQuery(),
      parser: (raw) =>
          PaginatedResponse<CourseModel>.fromLaravel(raw, CourseModel.fromJson),
    );
    return envelope.data!;
  }

  Future<CourseModel> details(String id) async {
    final envelope = await _remote.get<CourseModel>(
      ApiConstants.courseDetails(id),
      parser: (raw) => CourseModel.fromJson(raw as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<CourseContentModel> content(String id) async {
    final envelope = await _remote.get<CourseContentModel>(
      ApiConstants.courseContent(id),
      parser: (raw) => CourseContentModel.fromJson(raw as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<List<GradeItemModel>> grades(String id) async {
    final envelope = await _remote.get<List<GradeItemModel>>(
      ApiConstants.courseGrades(id),
      parser: (raw) => (raw as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(GradeItemModel.fromJson)
          .toList(),
    );
    return envelope.data!;
  }
}
