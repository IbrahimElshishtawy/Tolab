import '../../features/subjects/data/models.dart';
import '../fake_delay.dart';
import '../mock_data.dart';

class SubjectsFakeRepo {
  Future<List<Subject>> getSubjects() async {
    await fakeDelay();
    return mockSubjectsData.map((json) => Subject.fromJson(json)).toList();
  }

  Future<List<Lecture>> getLectures(int subjectId) async {
    await fakeDelay();
    return mockLecturesData.map((json) => Lecture.fromJson(json)).toList();
  }
}
