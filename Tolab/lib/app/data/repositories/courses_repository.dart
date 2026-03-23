import '../../core/utils/result.dart';
import '../datasources/courses_remote_data_source.dart';
import '../dto/pagination_query_dto.dart';
import '../models/course_content_model.dart';
import '../models/course_model.dart';
import '../models/grade_item_model.dart';
import '../models/paginated_response.dart';
import 'base_repository.dart';

class CoursesRepository with BaseRepository {
  CoursesRepository(this._remote);

  final CoursesRemoteDataSource _remote;

  Future<Result<PaginatedResponse<CourseModel>>> list(
    PaginationQueryDto query,
  ) => guard(() => _remote.list(query));

  Future<Result<CourseModel>> details(String id) =>
      guard(() => _remote.details(id));

  Future<Result<CourseContentModel>> content(String id) =>
      guard(() => _remote.content(id));

  Future<Result<List<GradeItemModel>>> grades(String id) =>
      guard(() => _remote.grades(id));
}
