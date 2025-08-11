import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/lecture.dart';
import '../models/exam.dart';
import '../models/link_model.dart';
import '../models/detail_section.dart';

class SubjectViewModel extends ChangeNotifier {
  final String subjectId;
  SubjectViewModel(this.subjectId);

  Subject? subject;
  List<Lecture> lectures = [];
  List<Exam> exams = [];
  List<LinkModel> links = [];
  List<DetailSection> details = [];

  bool isLoading = false;

  Future<void> loadSubjectData() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // محاكاة تحميل البيانات

    subject = Subject(
      id: subjectId,
      title: "برمجة متقدمة",
      teacherName: "د. أحمد",
      fileCount: 5,
    );

    lectures = [
      Lecture(id: 'l1', title: "المحاضرة الأولى", fileUrl: "link1.pdf"),
      Lecture(id: 'l2', title: "المحاضرة الثانية", fileUrl: "link2.pdf"),
    ];

    exams = [
      Exam(id: 'e1', title: "امتحان منتصف الترم", fileUrl: "midterm.pdf"),
    ];

    links = [
      LinkModel(
        id: 'link1',
        title: "الموقع الرسمي",
        url: "https://example.com",
      ),
    ];

    details = [
      DetailSection(title: "الوصف", content: "هذه مادة متقدمة في البرمجة..."),
    ];

    isLoading = false;
    notifyListeners();
  }
}
