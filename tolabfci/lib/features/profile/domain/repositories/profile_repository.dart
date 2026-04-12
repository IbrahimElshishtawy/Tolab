import '../../../../core/models/student_profile.dart';

abstract class ProfileRepository {
  Future<StudentProfile> fetchProfile();
}
