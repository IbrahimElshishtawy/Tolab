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
    final list = mockLecturesDataMap[subjectId] ?? [];
    return list.map((json) => Lecture.fromJson(json)).toList();
  }

  Future<List<Section>> getSections(int subjectId) async {
    await fakeDelay();
    final list = mockSectionsDataMap[subjectId] ?? [];
    return list.map((json) => Section.fromJson(json)).toList();
  }

  Future<List<Quiz>> getQuizzes(int subjectId) async {
    await fakeDelay();
    final list = mockQuizzesDataMap[subjectId] ?? [];
    return list.map((json) => Quiz.fromJson(json)).toList();
  }

  Future<List<Summary>> getSummaries(int subjectId) async {
    await fakeDelay();
    final list = mockSummariesDataMap[subjectId] ?? [];
    return list.map((json) => Summary.fromJson(json)).toList();
  }

  Future<void> createLecture(int subjectId, Map<String, dynamic> lectureData) async {
    await fakeDelay(1000);
  }

  Future<void> createSection(int subjectId, Map<String, dynamic> sectionData) async {
    await fakeDelay(1000);
  }

  Future<void> createQuiz(int subjectId, Map<String, dynamic> quizData) async {
    await fakeDelay(1200);
  }
}
