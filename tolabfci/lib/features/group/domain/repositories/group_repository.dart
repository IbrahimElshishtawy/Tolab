import '../../../../core/models/community_models.dart';

abstract class GroupRepository {
  Future<CourseGroup> getCourseGroup(String courseOfferingId);
}
